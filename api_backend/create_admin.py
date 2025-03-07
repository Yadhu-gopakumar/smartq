from app import db, Admin, bcrypt, app

with app.app_context():
    db.create_all()  # Ensure tables exist

    # Create Admin User
    username = "admin"
    password = "admin123"  # Change this!
    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    # Avoid duplicate admin creation
    existing_admin = Admin.query.filter_by(username=username).first()
    if existing_admin:
        print("Admin already exists!")
    else:
        new_admin = Admin(username=username, password_hash=hashed_password)
        db.session.add(new_admin)
        db.session.commit()
        print("Admin created successfully!")

