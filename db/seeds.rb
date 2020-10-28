Supplier.find_or_create_by(supplier_id: 'solidus').update(name: 'Solidus Store')

Store.find_or_create_by(store_id: 'urotuning').update(name: 'Urotuning', href: 'https://www.urotuning.com/collections/all/products')
Store.find_or_create_by(store_id: 'performancebyie').update(name: 'performancebyie', href: 'https://www.performancebyie.com/collections/all/products')
Store.find_or_create_by(store_id: 'bmptuning').update(name: 'bmptuning', href: 'https://www.bmptuning.com/collections/all/products')
Store.find_or_create_by(store_id: 'turn14').update(name: 'turn14', href: 'https://api.turn14.com')
Store.find_or_create_by(store_id: 'uspmotorsports').update(name: 'uspmotorsports', href: 'https://www.uspmotorsports.com/')
Store.find_or_create_by(store_id: 'ctsturbo').update(name: 'ctsturbo', href: 'https://www.ctsturbo.com/product-category/nissan/')

Section.find_or_create_by(section_id: 'Volkswagen-parts').update(name: 'Volkswagen', href: 'https://www.fcpeuro.com/Volkswagen-parts/')
Section.find_or_create_by(section_id: 'Audi-parts').update(name: 'Audi', href: 'https://www.fcpeuro.com/Audi-parts/')
Section.find_or_create_by(section_id: 'ECS-Audi').update(name: 'Audi', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=Audi')
Section.find_or_create_by(section_id: 'ECS-BMW').update(name: 'BMW', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=BMW')
Section.find_or_create_by(section_id: 'ECS-Volkswagen').update(name: 'Volkswagen', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=Volkswagen')
