desc 'To check Catalog from dropbox to turn14'
task catalog_check_against_turn14: :environment do
  file = Curb.open_uri(ENV['DROPBOX_URL'])
  turn14_ids = []
  CSV.parse(file,
            headers: true,
            header_converters: :symbol) do |row|
    turn14_ids << row[:turn14id]
  end
  puts turn14_ids
end
