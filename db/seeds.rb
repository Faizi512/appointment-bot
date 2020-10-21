# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Supplier.find_or_create_by(supplier_id: "solidus").update(name: "Solidus Store")
Store.find_or_create_by(store_id: "urotuning").update(name: "Urotuning", href:"https://www.urotuning.com/collections/all/products")
Store.find_or_create_by(store_id: "performancebyie").update(name: "performancebyie", href:"https://www.performancebyie.com/collections/all/products")
Store.find_or_create_by(store_id: "bmptuning").update(name: "bmptuning", href:"https://www.bmptuning.com/collections/all/products")
Store.find_or_create_by(store_id: 'turn14').update(name: 'turn14', href: 'https://api.turn14.com')
Store.find_or_create_by(store_id: 'uspmotorsports').update(name: 'uspmotorsports', href: 'https://www.uspmotorsports.com/')
Store.find_or_create_by(store_id: 'ctsturbo').update(name: 'ctsturbo', href: 'https://www.ctsturbo.com/product-category/nissan/')
Section.find_or_create_by(name: "Volkswagen",section_id: "Volkswagen-parts", href: "https://www.fcpeuro.com/Volkswagen-parts/")
Section.find_or_create_by(name: "Audi",section_id: "Audi-parts", href: "https://www.fcpeuro.com/Audi-parts/")