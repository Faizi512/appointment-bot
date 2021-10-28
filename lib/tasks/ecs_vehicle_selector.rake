desc 'To scrape vehicle selector data of AUDI, BMW, Volkswagen from ecstuning.com'
task ecs_vehicle_selector: :environment do
  sections = Section.where(section_id: %w[ECS-Audi ECS-BMW ECS-Volkswagen])
  # sections = Section.where(section_id: ["ECS-Audi"])
  # sections = Section.where(section_id: ["ECS-BMW"])
  # sections = Section.where(section_id: ["ECS-Volkswagen"])
  sections.each do |section|
    step_1 = base_ecs_vehicle_selector(section.href)

    step_1['data'].each do |step1|
      step_2 = ecs_vehicle_selector(step_1['url'], step1)
      if step_2['data'].blank?
        obj = EcsVehicleSelector.create(vehicle: section.name, 
          step_1['category'].downcase.to_s.to_sym => step1.split('::').last)
        puts "step_2 #{obj.print_data}"
        next
      end

      step_2['data'].each do |step2|
        step_3 = ecs_vehicle_selector(step_2['url'], step2)
        if step_3['data'].blank?
          obj = EcsVehicleSelector.create(vehicle: section.name, step_1['category'].downcase.to_s.to_sym => step1.split('::').last, step_2['category'].downcase.to_s.to_sym => step2.split('::').last)
          puts "step_3 #{obj.print_data}"
          next
        end

        step_3['data'].each do |step3|
          step_4 = ecs_vehicle_selector(step_3['url'], step3)
          if step_4['data'].blank?
            step_3['category'] = 'Config' if step_4['category'] == 'Body Type'
            obj = EcsVehicleSelector.create(vehicle: section.name, step_1['category'].downcase.to_s.to_sym => step1.split('::').last, step_2['category'].downcase.to_s.to_sym => step2.split('::').last, step_3['category'].downcase.to_s.to_sym => step3.split('::').last)
            puts "step_4 #{obj.print_data}"
            next
          end

          step_4['data'].each do |step4|
            step_5 = ecs_vehicle_selector(step_4['url'], step4)
            if step_5['data'].blank?
              step_4['category'] = 'Config' if step_4['category'] == 'Body Type'
              obj = EcsVehicleSelector.create(vehicle: section.name, step_1['category'].downcase.to_s.to_sym => step1.split('::').last, step_2['category'].downcase.to_s.to_sym => step2.split('::').last, step_3['category'].downcase.to_s.to_sym => step3.split('::').last, step_4['category'].downcase.to_s.to_sym => step4.split('::').last)
              puts "step_5 #{obj.print_data}"
              next
            end

            step_5['data'].each do |step5|
              step_6 = ecs_vehicle_selector(step_5['url'], step5)
              next if step_6['data'].present?

              step_5['category'] = 'Config' if step_5['category'] == 'Body Type'
              obj = EcsVehicleSelector.create(vehicle: section.name, step_1['category'].downcase.to_s.to_sym => step1.split('::').last, step_2['category'].downcase.to_s.to_sym => step2.split('::').last, step_3['category'].downcase.to_s.to_sym => step3.split('::').last, step_4['category'].downcase.to_s.to_sym => step4.split('::').last, step_5['category'].downcase.to_s.to_sym => step5.split('::').last)
              puts "step_6 #{obj.print_data}"
              next
            end
          end
        end
      end
    end
  end
end

def ecs_vehicle_selector(section_url, v_step)
  v_hash = {}
  v_hash['url'] = section_url + '&' + v_step.split('::').first + '=' + v_step.split('::').last
  v_hash['url'].sub!('+', '%2B') if v_hash['url'].include? '+'
  v_step_doc = Curb.get_doc(v_hash['url'])
  v_step_array = v_step_doc.at('p').children.text.split(/\n/)
  if v_step_array.length > 0
    v_hash['category'] = v_step_array.first.split('::').second if v_step_array.first.split('::').last == 'n'
    if v_hash['category'].nil? && v_hash['url'].include?('Audi') && !v_step_array.last.split('::').first.include?('END')
      v_hash['category'] = 'Chassis' if v_step_array.first.include? 'vstep_3'
      v_hash['category'] = 'Engine' if v_step_array.first.include? 'vstep_4'
      v_hash['category'] = 'Drivetrain' if v_step_array.first.include? 'vstep_5'
      v_hash['category'] = 'Body Type' if v_step_array.first.include? 'vstep_6'
      v_hash['data'] = []
      v_hash['data'] << v_step_array.first if v_hash['category']
    elsif v_hash['category'].nil? && v_hash['url'].include?('Audi') && (v_step_array.length > 1) && v_step_array.last.split('::').first.include?('END')
      v_hash['category'] = 'Chassis' if v_step_array.first.include? 'vstep_3'
      v_hash['category'] = 'Engine' if v_step_array.first.include? 'vstep_4'
      v_hash['category'] = 'Drivetrain' if v_step_array.first.include? 'vstep_5'
      v_hash['category'] = 'Body Type' if v_step_array.first.include? 'vstep_6'
      v_hash['data'] = []
      v_hash['data'] << v_step_array.first if v_hash['category']
    else
      v_step_array.pop if v_step_array.last.split('::').first.include? 'END'
      v_hash['data'] = v_step_array.drop(1) if v_hash['category']
    end
  end
  v_hash
rescue StandardError => e
  puts e.message
  UserMailer.with(user: e, script: "ecs_vehicle_selector").issue_in_script.deliver_now
end

def base_ecs_vehicle_selector(section_url)
  v_hash = {}
  v_hash['url'] = section_url
  v_step_doc = Curb.get_doc(v_hash['url'])
  v_step_array = v_step_doc.at('p').children.text.split(/\n/)
  if v_step_array.length > 0
    v_hash['category'] = v_step_array.first.split('::').second if v_step_array.first.split('::').last == 'n'
    v_step_array.pop if v_step_array.last.split('::').first.include? 'END'
    v_hash['data'] = v_step_array.drop(1) if v_hash['category']
  end
  v_hash
rescue StandardError => e
  puts e.message
  UserMailer.with(user: e, script: "ecs_vehicle_selector").issue_in_script.deliver_now
end
