namespace :jira do
  desc "Синхронизация дат с JIRA по API"
  task sync_dates: :environment do
    
    JIRA_DOMAIN = "groupffive.atlassian.net"
    JIRA_EMAIL = "p31153224@gmail.com"
    JIRA_API_TOKEN = "ATATT3xFfGF0y1jvRdiXHumT48xvCrC760E7QsiEI_n-G_o_KtEQIgPlRNJNC93NSXJgMGvB5G-kOtNHyQ32poUMa6Ic-ylo5jFOr2H_8URDt1JvAcavjKPGjdsfqrUAmd5WuahEZn6i0cot78pzKXSeqslxSpl6nH_g3H0ytG7GcSLyD3HW344=6A33FEAC"

    require 'net/http'
    require 'uri'
    require 'json'

    puts "Начинаем автоматическую синхронизацию с JIRA..."

    jira_id_field = CustomField.find_by(name: 'JIRA ID')
    target_date_field = CustomField.find_by(name: 'Желаемая дата переноса')
    status_review = Status.find_by(name: 'Ожидает согласования')

    if !jira_id_field || !target_date_field || !status_review
      puts "Ошибка: Не найдены нужные поля."
      next
    end

    WorkPackage.all.each do |wp|
      jira_id = wp.custom_value_for(jira_id_field)&.value
      next if jira_id.blank?

      uri = URI.parse("https://#{JIRA_DOMAIN}/rest/api/2/issue/#{jira_id}")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(JIRA_EMAIL, JIRA_API_TOKEN)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == "200"
        data = JSON.parse(response.body)
        jira_due_date = data.dig('fields', 'duedate')

        if jira_due_date.present? && wp.due_date.to_s != jira_due_date.to_s
          puts "Для #{jira_id} найден новый дедлайн: #{jira_due_date}."
          
          cv = wp.custom_values.find_or_initialize_by(custom_field_id: target_date_field.id)
          cv.value = jira_due_date
          cv.save
          wp.status = status_review
          wp.save(validate: false) 

          puts "Задача ##{wp.id} обновлена: создан запрос на перенос."
        end
      end
    end
    
    puts "Синхронизация завершена."
  end
end