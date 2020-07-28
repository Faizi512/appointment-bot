task :catalog_check_against_turn14 => :environment do
	retries = 0
	file = begin
		retries ||= 0
		open(ENV['DROPBOX_URL'])
	rescue => exception
		sleep 1
		retry if (retries += 1) < 3
	end
	turn14_ids = []
	CSV.parse(file,
			  headers: true,
			  header_converters: :symbol) do |row|
		turn14_ids << row[:turn14id]		
	end
end