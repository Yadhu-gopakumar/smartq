from flask import Flask, request, jsonify, session, render_template, redirect, url_for, flash
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, unset_jwt_cookies
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
import os
from flask_bcrypt import Bcrypt
from werkzeug.utils import secure_filename
from flask_migrate import Migrate
from models import db, Admin, User, MenuItem, Cart, Booking  # Import models
from datetime import datetime


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///canteen.db'
app.config['JWT_SECRET_KEY'] = '8590659295ysmartq'
app.config['SECRET_KEY'] = '8590659295ysmartq'
app.config['UPLOAD_FOLDER'] = "static/uploads"

UPLOAD_FOLDER = os.path.join(os.getcwd(), 'static/uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Initialize extensions
db.init_app(app)  # Initialize SQLAlchemy
migrate = Migrate(app, db)
jwt = JWTManager(app)
CORS(app, origins=["*"])
bcrypt = Bcrypt(app)

# Ensure 'static/uploads' directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username and password are required'}), 400

    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 409

    try:
        hashed_password = generate_password_hash(data['password'])
        user = User(username=data['username'], password_hash=hashed_password, is_admin=data.get('is_admin', False))
        db.session.add(user)
        db.session.commit()
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Registration failed', 'details': str(e)}), 500


@app.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(username=data['username']).first()
    if user and check_password_hash(user.password_hash, data['password']):
        token = create_access_token(identity={'id': user.id, 'is_admin': user.is_admin})
        return jsonify({'access_token': token})
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    response = jsonify({'message': 'User logged out successfully'})
    unset_jwt_cookies(response)
    return response

@app.route('/menu', methods=['GET'])
def get_menu():
    menu = MenuItem.query.all()
    return jsonify([{'id': item.id, 'name': item.name, 'price': item.price, 'available': item.available, 'rating': item.rating, 'image_url': item.image_url} for item in menu])

@app.route('/menu/edit/<int:item_id>')
def edit_menu_page(item_id):

    item = MenuItem.query.get_or_404(item_id)
    return render_template("update_menu.html", item=item)


@app.route('/menu/<int:item_id>/update', methods=['POST'])

def update_menu(item_id):

    item = MenuItem.query.get(item_id)
    if not item:
        return jsonify({'error': 'Item not found'}), 404

    # Update form fields
    item.name = request.form.get('name', item.name)
    item.price = request.form.get('price', item.price)
    item.available = bool(request.form.get('available'))  # Checkbox handling

    # Handle Image Upload
    if 'image' in request.files:
        image = request.files['image']
        if image.filename:
            filename = secure_filename(image.filename)
            upload_folder = app.config['UPLOAD_FOLDER']

            # ✅ Ensure the folder exists
            os.makedirs(upload_folder, exist_ok=True)

            image_path = os.path.join(upload_folder, filename)
            image.save(image_path)

            # ✅ Store relative URL
            item.image_url = f"/static/uploads/{filename}"

    db.session.commit()
    return redirect(url_for('admin_dashboard'))




@app.route('/admin/delete_menu/<int:item_id>', methods=['POST'])

def delete_menu_item(item_id):

    item = MenuItem.query.get(item_id)
    if not item:
        return jsonify({'error': 'Item not found'}), 404

    # If the item has an image, delete the file
    if item.image_url:
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], os.path.basename(item.image_url))
        if os.path.exists(image_path):
            os.remove(image_path)

    # Remove the item from the database
    db.session.delete(item)
    db.session.commit()

    return redirect(url_for('admin_dashboard'))



@app.route('/cart', methods=['POST'])
@jwt_required()
def add_to_cart():
    user_id = get_jwt_identity()  # ✅ Now directly a string

    data = request.json
    cart_item = Cart(user_id=int(user_id), item_id=data['item_id'], quantity=data.get('quantity', 1))
    db.session.add(cart_item)
    db.session.commit()
    return jsonify({'message': 'Item added to cart'})




@app.route('/cart', methods=['GET'])
@jwt_required()
def get_cart():
    user_id = get_jwt_identity()['id']
    cart = Cart.query.filter_by(user_id=user_id).all()
    return jsonify([{'item_id': item.item_id, 'quantity': item.quantity, 'image_url': item.image_url} for item in cart])




@app.route('/cart/<int:item_id>', methods=['DELETE'])
@jwt_required()
def remove_from_cart(item_id):
    user_id = get_jwt_identity()['id']
    cart_item = Cart.query.filter_by(user_id=user_id, item_id=item_id).first()
    if cart_item:
        db.session.delete(cart_item)
        db.session.commit()
        return jsonify({'message': 'Item removed from cart'})
    return jsonify({'error': 'Item not found in cart'}), 404




@app.route('/bookings', methods=['POST'])
@jwt_required()
def add_booking():
    user_id = get_jwt_identity()['id']
    data = request.json
    if not data or 'items' not in data:
        return jsonify({'error': 'Invalid request, items required'}), 400

    try:
        booking = Booking(user_id=user_id, items=data['items'], status='Pending', date_time=datetime.utcnow())  # ✅ Store timestamp
        db.session.add(booking)
        db.session.commit()
        return jsonify({'message': 'Booking added successfully', 'booking_id': booking.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to add booking', 'details': str(e)}), 500



@app.route('/bookings/user', methods=['GET'])
@jwt_required()
def get_user_bookings():
    user_id = get_jwt_identity()['id']
    bookings = Booking.query.filter_by(user_id=user_id).all()
    return jsonify([{
        'id': booking.id,
        'items': booking.items,
        'status': booking.status,
        'date_time': booking.date_time.strftime('%Y-%m-%d %H:%M:%S')  # ✅ Format timestamp
    } for booking in bookings])



@app.route('/bookings', methods=['PUT'])
@jwt_required()
def update_booking():
    user = get_jwt_identity()
    if not user['is_admin']:
        return jsonify({'error': 'Unauthorized'}), 403
    data = request.json
    booking = Booking.query.get(data['booking_id'])
    if not booking:
        return jsonify({'error': 'Booking not found'}), 404
    booking.status = data['status']
    db.session.commit()
    return jsonify({'message': 'Booking status updated successfully'})




# Admin Login
@app.route('/admin', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        admin = Admin.query.filter_by(username=username).first()
        if admin and bcrypt.check_password_hash(admin.password_hash, password):
            session['admin_logged_in'] = True
            session.permanent = True
            return redirect(url_for('admin_dashboard'))
        flash('Invalid Credentials', 'danger')
    return render_template('admin_login.html')

# Admin Dashboard
@app.route('/admin/dashboard')
def admin_dashboard():
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    menu_items = MenuItem.query.all()
    return render_template('admin_dashboard.html', menu_items=menu_items)



@app.route('/admin/add_menu', methods=['GET', 'POST'])
def admin_add_menu():
    if request.method == 'POST':
        name = request.form.get('name')
        price = request.form.get('price')
        available = 'available' in request.form

        image_url = None  # Initialize image_url

        # Handle Image Upload
        if 'image' in request.files:
            image = request.files['image']
            if image.filename:
                filename = secure_filename(image.filename)
                upload_folder = app.config['UPLOAD_FOLDER']

                # ✅ Ensure the upload folder exists
                os.makedirs(upload_folder, exist_ok=True)

                image_path = os.path.join(upload_folder, filename)
                image.save(image_path)

                # ✅ Store relative URL (fix the issue)
                image_url = f"/static/uploads/{filename}"

        # Save to database (fix: use `image_url`, not `item.image_url`)
        new_item = MenuItem(name=name, price=price, image_url=image_url, available=available)
        db.session.add(new_item)
        db.session.commit()

        return redirect(url_for('admin_dashboard'))

    return render_template('admin_add_menu.html')




# View Orders & Update Status
@app.route('/admin/orders')
def admin_orders():
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    orders = Booking.query.all()
    return render_template('admin_orders.html', orders=orders)

@app.route('/admin/update_order/<int:order_id>', methods=['POST'])
def update_order(order_id):
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    order = Booking.query.get_or_404(order_id)
    order.status = request.form['status']
    db.session.commit()
    flash('Order Status Updated', 'success')
    return redirect(url_for('admin_orders'))



@app.route('/admin/view_menu')
def view_menu():
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))

    menu_items = MenuItem.query.all()
    return render_template('view_menu.html', menu_items=menu_items)



# Admin Logout
@app.route('/admin/logout')
def admin_logout():
    session.pop('admin_logged_in', None)
    flash('Logged Out Successfully', 'success')
    return redirect(url_for('admin_login'))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()

    app.run(debug=True)

