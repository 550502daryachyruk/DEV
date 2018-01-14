require 'green_shoes'
COUNT = 17

Shoes.app title: 'Eject', width: 580, height: 700 do
  para 'Input device', margin: 10
  @line = edit_line width: 400, margin: 10
  @item = button 'Disconnect device', margin: 10
  @linee = edit_line width: 400, margin: 10
  @itemm = button 'Connect device', margin: 10
  @buttom = button 'Get list of devices', margin_left: 430
  @buttom.click do
    @i = Thread.new do
      @edit_box = edit_box width: 530, height: 500, margin: 10
      @uuid = Array.new(COUNT)
        @uuid.map! do |item|
            item = `uuidgen - create a new UUID value`
        end
        @edit_box.text = ''
          i = 5
          j = 0
            @array = Array.new(COUNT)
            Thread.current['array'] = @array
            @array[j] = {:name => '', :man => '', :guid => '', :device_part => '', :provider => '', :driver_name => '', :bus => '', :driver_file => ''}
            information = `lshw`

            information.split("\n").each do |item|
              if item.include?'description'
                if i > 0
                  i -= 1
                  next
                end
                @array[j][:name] = item.split(': ')[1]
              end

              if item.include?'vendor'
                if i > 0
                  i -= 1
                  next
                end
                @array[j][:man] = item.split(': ')[1]
              end

              if item.include?'bus info'
                if i > 0
                  i -= 1
                  next
                end
                @string = ''
                item.split(': ')[1].split('')[4..15].each { |item| @string += item }
                @array[j][:device_part] = @string.delete('@')
                @string = ''
                item.split(': ')[1].split('')[0..3].each { |item| @string += item }
                @array[j][:bus] = @string.delete('@')
              end

              if item.include?'configuration'
                item.split(' ').each do |line|
                  if line.include?'driver='
                    @array[j][:driver_name] = line.split('=')[1]
                    j += 1
                    @array[j] = {:name => '', :man => '', :guid => '', :device_part => '', :provider => '', :driver_name => '', :bus => '', :driver_file => ''}
                    break
                  end
                end
              end
            end
            @array.each do |device|
              if device[:name] == 'DVD-RAM writer'
                device[:driver_file] = 'ERROR'
                break
              end
              Dir.chdir("/sys/bus//#{device[:bus]}//devices/#{device[:device_part]}")
              info = IO.read('modalias')
              Dir.chdir("/sbin")
              info = `modinfo #{info}`
              device[:driver_file] = if info == ''
                                       'ERROR'
                                     else
                                       info.split("\n")[0].split(' ')[1]
                                     end
            end
            i = 0
            @array.delete(@array.last())
            @array.each do |item|
              item[:guid] = @uuid[i]
              i += 1
            end
            i = 1
            @array.each do |item|
              @edit_box.text += "Device # #{i}\n"
              @edit_box.text += "Name: #{item[:name]}\n"
              @edit_box.text += "Manufacturer: #{item[:man]}\n"
              @edit_box.text += "Provider: Advanced Micro Devices, Inc.\n"
              @edit_box.text += "Device Path: #{item[:device_part]}\n"
              @edit_box.text += "Driver Name: #{item[:driver_name]}\n"
              @edit_box.text += "Sys file: #{item[:driver_file]}\n"
              @edit_box.text += "GUID: #{item[:guid]}\n"
              i += 1
            end
    end
  end
  @item.click do
    name_device = @line.text
  @i['array'].each do |item|
      if item[:name] == name_device
        @time = item[:device_part]
        Dir.chdir("/sys/bus/#{item[:bus]}/drivers/#{item[:driver_name]}")
        `echo #{item[:device_part]} | sudo tee -a unbind`
        break
      end
    end
  end
  @itemm.click do
    name_device = @linee.text
    @i['array'].each do |item|
      if item[:name] == name_device
        @time = item[:device_part]
        Dir.chdir("/sys/bus/#{item[:bus]}/drivers/#{item[:driver_name]}")
        `echo #{@time} | sudo tee -a bind`
        break
      end
    end
  end
end
