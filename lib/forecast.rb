require 'rexml/document'

class Forecast
  attr_reader :datetime, :cloudiness, :temperature_range, :wind_range

  CLOUDINESS = %w[Ясно Малооблачно Облачно Пасмурно].freeze
  DAYTIMES = {
    9 => 'утро',
    15 => 'день',
    21 => 'вечер',
    3 => 'ночь'
  }.freeze

  def self.from_xml_node(node)
    day = node.attributes['day']
    month = node.attributes['month']
    year = node.attributes['year']
    hour = node.attributes['hour']
    temperature_min = node.elements['TEMPERATURE'].attributes['min']
    temperature_max = node.elements['TEMPERATURE'].attributes['max']
    wind_min = node.elements['WIND'].attributes['min']
    wind_max = node.elements['WIND'].attributes['max']
    cloudiness = node.elements['PHENOMENA'].attributes['cloudiness'].to_i
    new({ datetime: Time.new(year, month, day, hour),
          cloudiness: cloudiness,
          temperature_range: temperature_min..temperature_max,
          wind_range: wind_min..wind_max })
  end

  def initialize(params)
    @time = params[:datetime]
    @cloudiness = params[:cloudiness]
    @temperature_range = params[:temperature_range]
    @wind_range = params[:wind_range]
  end

  def to_s
    <<~FORECAST
      #{date_to_s}, #{DAYTIMES[@time.hour]}
      #{@temperature_range}, ветер #{@wind_range} м/с, #{CLOUDINESS[@cloudiness]}
    FORECAST
  end

  private

  def date_to_s
    today? ? 'Сегодня' : @time.strftime('%d.%m.%Y')
  end

  def today?
    now = Time.now
    @time.day == now.day && @time.year == now.year && @time.month == now.month
  end
end
