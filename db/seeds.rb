Supplier.find_or_create_by(supplier_id: 'solidus').update(name: 'Solidus Store')

#shopify stores
Store.find_or_create_by(store_id: 'urotuning').update(name: 'Urotuning', href: 'https://www.urotuning.com/collections/all') # store_id:
# Store.find_or_create_by(store_id: 'uroTuning').update(name: 'Uro_tuning', href: 'https://www.urotuning.com/collections/all/products')
Store.find_or_create_by(store_id: 'performancebyie').update(name: 'performancebyie', href: 'https://www.performancebyie.com/collections/all/products')
Store.find_or_create_by(store_id: 'bmptuning').update(name: 'bmptuning', href: 'https://www.bmptuning.com/collections/all/products')
Store.find_or_create_by(store_id: 'maxtondesignusa').update(name: 'Maxton Design USA', href: 'https://maxtondesignusa.net/collections/all/products')
Store.find_or_create_by(store_id: 'NeuspeedRSWheels').update(name: 'Neuspeed RSWheels', href: 'https://neuspeedrswheels.com/products')
Store.find_or_create_by(store_id: 'mmrperformance').update(name: 'MMR Performance', href: 'https://www.mmrshop.co.uk/products')
#end shopify stores

Store.find_or_create_by(store_id: 'turn14').update(name: 'turn14', href: 'https://api.turn14.com')
Store.find_or_create_by(store_id: 'uspmotorsports').update(name: 'uspmotorsports', href: 'https://www.uspmotorsports.com/')
Store.find_or_create_by(store_id: 'ctsturbo').update(name: 'ctsturbo', href: 'https://www.ctsturbo.com/product-category/accessories/')
Store.find_or_create_by(store_id: 'ecstuning').update(name: 'ecstuning', href: 'https://www.ecstuning.com')
Store.find_or_create_by(store_id: 'ebay').update(name: 'ebay', href: 'https://www.ebay.com/sch/usedeuroparts/m.html?_nkw=&_armrs=1&_ipg=&_from=')
Store.find_or_create_by(store_id: 'tunerprice').update(name: 'tunerprice', href: 'https://www.tunerprice.com/wholesale')
Store.find_or_create_by(store_id: 'bcracing').update(name: 'bcracing', href: 'https://portal.nowcommerce.com/signin.aspx')
Store.find_or_create_by(store_id: 'neuspeed').update(name: 'neuspeed', href: '')
Store.find_or_create_by(store_id: 'unitronic').update(name: 'unitronic', href: 'https://chip2.unitronic.ca/hw-api/get-stock.php?')
Store.find_or_create_by(store_id: 'tsw_wheels').update(name: 'tsw_wheels', href: 'https://www.tsw.com/api/inv-SpcPrc_v3.php?key=tsw01xml&type=csv&l=.40&brand=&funct=All')
Store.find_or_create_by(store_id: 'holly_performance').update(name: 'holly_performance', href: 'https://b2b.holley.com/data/atp/?api_key=0.shxzht2953')
Store.find_or_create_by(store_id: 'xforce').update(name: 'xforce', href: 'https://secure-wms.com')
Store.find_or_create_by(store_id: '034 motorsport').update(name: '034 motorsport', href: 'https://docs.google.com/spreadsheets/d/13O0EqWI5aTyMO_egXHFe1QSkCUWxjZ9iztgfyk1n7vo/edit#gid=1302382781')
Store.find_or_create_by(store_id: 'parts_authority').update(name: 'Parts Authority', href: '')
Store.find_or_create_by(store_id: 'thmotorsports').update(name: 'TH Motorsports', href: 'https://thmotorsports.com/')

Section.find_or_create_by(section_id: 'Volkswagen-parts').update(name: 'Volkswagen', href: 'https://www.fcpeuro.com/Volkswagen-parts/')
Section.find_or_create_by(section_id: 'Audi-parts').update(name: 'Audi', href: 'https://www.fcpeuro.com/Audi-parts/')
Section.find_or_create_by(section_id: 'ECS-Audi').update(name: 'Audi', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=Audi')
Section.find_or_create_by(section_id: 'ECS-BMW').update(name: 'BMW', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=BMW')
Section.find_or_create_by(section_id: 'ECS-Volkswagen').update(name: 'Volkswagen', href: 'https://www.ecstuning.com/includes/vehicleMap.cgi?vehicleSelection=1&vstep_1=Volkswagen')


# Wordpress websites
Store.find_or_create_by(store_id: 'vargas_turbo').update(name: 'vargas_turbo', href: 'https://vargasturbo.com/product-search/')