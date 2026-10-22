import logging, os, re, secrets
from datetime import datetime, timezone
from decimal import Decimal
import mysql.connector
from mysql.connector import Error as MySQLError
from flask import Flask, jsonify, render_template, request

app = Flask(__name__, template_folder='templates', static_folder='static')
logging.basicConfig(level=os.getenv('LOG_LEVEL', 'INFO'))
logger = logging.getLogger('cloudstore')
DB = {
    'host': os.environ.get('DB_HOST', '127.0.0.1'),
    'port': int(os.environ.get('DB_PORT', '3306')),
    'database': os.environ.get('DB_NAME', 'cloudstore'),
    'user': os.environ.get('DB_USER', 'cloudstore_app'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'connection_timeout': int(os.environ.get('DB_CONNECT_TIMEOUT', '5')),
    'ssl_ca': os.environ.get('DB_SSL_CA', '/etc/cloudstore/global-bundle.pem'),
    'ssl_verify_cert': True,
    'ssl_verify_identity': True,
}

def db():
    if not DB['password']:
        raise RuntimeError('DB_PASSWORD is not configured')
    return mysql.connector.connect(**DB)

def close(conn):
    if conn and conn.is_connected():
        conn.close()

def clean_product(row):
    row['price'] = float(row['price'])
    row['stock_quantity'] = int(row['stock_quantity'])
    row['is_active'] = bool(row['is_active'])
    row['featured'] = bool(row.get('featured', False))
    return row

@app.get('/')
def home():
    return render_template('index.html')

@app.get('/health')
def health():
    return 'healthy', 200, {'Content-Type': 'text/plain; charset=utf-8'}

@app.get('/api/health')
def api_health():
    conn = None
    try:
        conn = db(); cur = conn.cursor(); cur.execute('SELECT 1'); cur.fetchone(); cur.close()
        return jsonify({'application': 'ok', 'database': 'ok'})
    except Exception:
        logger.exception('Database health check failed')
        return jsonify({'application': 'ok', 'database': 'unavailable'}), 503
    finally:
        close(conn)

@app.get('/api/categories')
def categories():
    conn = None
    try:
        conn = db(); cur = conn.cursor(dictionary=True)
        cur.execute('''SELECT c.category_id, c.category_name, c.description,
                       COUNT(p.product_id) AS product_count
                       FROM categories c LEFT JOIN products p
                       ON p.category_id=c.category_id AND p.is_active=1
                       GROUP BY c.category_id,c.category_name,c.description
                       ORDER BY c.category_name''')
        return jsonify(cur.fetchall())
    except MySQLError:
        logger.exception('Could not load categories')
        return jsonify({'error': 'Categories are temporarily unavailable.'}), 503
    finally:
        close(conn)

@app.get('/api/products')
def products():
    conn = None
    q = request.args.get('q', '').strip()[:100]
    category = request.args.get('category', '').strip()[:100]
    sort = {'featured':'p.featured DESC,p.created_at DESC','price-low':'p.price ASC',
            'price-high':'p.price DESC','name':'p.product_name ASC'}.get(request.args.get('sort','featured'), 'p.featured DESC,p.created_at DESC')
    try:
        conn = db(); cur = conn.cursor(dictionary=True)
        sql = '''SELECT p.product_id,p.category_id,c.category_name,p.sku,p.brand,
                 p.product_name,p.description,p.price,p.stock_quantity,p.image_url,
                 p.badge,p.featured,p.is_active FROM products p
                 JOIN categories c ON c.category_id=p.category_id WHERE p.is_active=1'''
        params = []
        if q:
            sql += ' AND (p.product_name LIKE %s OR p.brand LIKE %s OR p.description LIKE %s OR p.sku LIKE %s)'
            term = f'%{q}%'; params.extend([term,term,term,term])
        if category and category.lower() != 'all':
            sql += ' AND c.category_name=%s'; params.append(category)
        sql += f' ORDER BY {sort} LIMIT 100'
        cur.execute(sql, tuple(params))
        return jsonify([clean_product(r) for r in cur.fetchall()])
    except MySQLError:
        logger.exception('Could not load products')
        return jsonify({'error':'Products are temporarily unavailable.'}), 503
    finally:
        close(conn)

@app.get('/api/products/<int:product_id>')
def product_detail(product_id):
    conn = None
    try:
        conn = db(); cur = conn.cursor(dictionary=True)
        cur.execute('''SELECT p.product_id,p.category_id,c.category_name,p.sku,p.brand,
                       p.product_name,p.description,p.price,p.stock_quantity,p.image_url,
                       p.badge,p.featured,p.is_active FROM products p
                       JOIN categories c ON c.category_id=p.category_id
                       WHERE p.product_id=%s AND p.is_active=1''', (product_id,))
        row = cur.fetchone()
        return (jsonify(clean_product(row)), 200) if row else (jsonify({'error':'Product not found.'}),404)
    except MySQLError:
        logger.exception('Could not load product detail')
        return jsonify({'error':'Product details are temporarily unavailable.'}),503
    finally:
        close(conn)

@app.post('/api/orders')
def create_order():
    """Demo checkout: records a sample order; no payment is processed."""
    payload = request.get_json(silent=True) or {}
    customer = payload.get('customer') or {}; items = payload.get('items') or []
    name = str(customer.get('name','')).strip()[:150]
    email = str(customer.get('email','')).strip().lower()[:150]
    phone = str(customer.get('phone','')).strip()[:20]
    address = str(payload.get('shipping_address','')).strip()[:1000]
    if len(name)<2 or not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email):
        return jsonify({'error':'Enter a valid name and email address.'}),400
    if len(address)<8: return jsonify({'error':'Enter a complete shipping address.'}),400
    if not isinstance(items,list) or not items or len(items)>30:
        return jsonify({'error':'Your cart is empty or contains too many items.'}),400
    quantities = {}
    try:
        for item in items:
            pid=int(item.get('product_id',0)); qty=int(item.get('quantity',0))
            if pid<=0 or qty<=0 or qty>20: raise ValueError
            quantities[pid]=quantities.get(pid,0)+qty
        if any(q>20 for q in quantities.values()): raise ValueError
    except (TypeError,ValueError,AttributeError):
        return jsonify({'error':'One or more cart quantities are invalid.'}),400
    conn = None
    try:
        conn=db(); conn.start_transaction(); cur=conn.cursor(dictionary=True)
        cur.execute('''INSERT INTO customers(full_name,email,phone) VALUES(%s,%s,%s)
                       ON DUPLICATE KEY UPDATE full_name=VALUES(full_name),phone=VALUES(phone)''', (name,email,phone or None))
        cur.execute('SELECT customer_id FROM customers WHERE email=%s',(email,)); customer_id=cur.fetchone()['customer_id']
        order_no='CS'+datetime.now(timezone.utc).strftime('%y%m%d')+secrets.token_hex(3).upper()
        cur.execute('''INSERT INTO orders(customer_id,order_number,order_status,total_amount,shipping_address)
                       VALUES(%s,%s,'PENDING',0,%s)''',(customer_id,order_no,address))
        order_id=cur.lastrowid; total=Decimal('0.00')
        for pid,qty in quantities.items():
            cur.execute('''SELECT product_id,product_name,price,stock_quantity FROM products
                           WHERE product_id=%s AND is_active=1 FOR UPDATE''',(pid,))
            product=cur.fetchone()
            if not product: raise ValueError('A product in your cart is no longer available.')
            if int(product['stock_quantity'])<qty: raise ValueError(f"Not enough stock for {product['product_name']}.")
            price=Decimal(str(product['price'])); total += price*qty
            cur.execute('INSERT INTO order_items(order_id,product_id,quantity,unit_price) VALUES(%s,%s,%s,%s)',(order_id,pid,qty,price))
            cur.execute('UPDATE products SET stock_quantity=stock_quantity-%s WHERE product_id=%s AND stock_quantity>=%s',(qty,pid,qty))
            if cur.rowcount != 1: raise ValueError(f"Stock changed for {product['product_name']}. Please retry.")
        cur.execute('UPDATE orders SET total_amount=%s WHERE order_id=%s',(total,order_id)); conn.commit()
        return jsonify({'message':'Demo order placed successfully. No payment was processed.',
                        'order_id':order_id,'order_number':order_no,'total_amount':f'{total:.2f}'}),201
    except ValueError as exc:
        if conn and conn.is_connected(): conn.rollback()
        return jsonify({'error':str(exc)}),400
    except MySQLError:
        if conn and conn.is_connected(): conn.rollback()
        logger.exception('Could not create demo order')
        return jsonify({'error':'Order could not be saved. Please try again.'}),503
    finally:
        close(conn)

@app.errorhandler(404)
def not_found(_error):
    if request.path.startswith('/api/'): return jsonify({'error':'Not found.'}),404
    return render_template('index.html'),200

if __name__ == '__main__':
    app.run(host='127.0.0.1',port=8000,debug=False)
