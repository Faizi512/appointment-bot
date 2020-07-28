task :catalog_check_against_turn14 => :environment do
	url = "https://www.dropbox.com/s/9i60spevrl4j791/turn14-mpns.csv?raw=1"
	turn14_ids = []
	CSV.parse(open(url),
			  headers: true,
			  header_converters: :symbol) do |row|
		turn14_ids << row[:turn14id]		
	end

end