require 'spec_helper'

describe Fias::Name::Long do
  {
    'г Краснодар' => ['Краснодар', 'город', 'г'],
    'г. Краснодар' => ['Краснодар', 'город', 'г'],
    'Краснодар город' => ['Краснодар', 'город', 'г'],
    'Раменский район' => ['Раменский', 'район', 'р-н'],
    'Ямало-Ненецкий АО' => ['Ямало-Ненецкий', 'автономный округ', 'АО'],
    'Еврейский автономный округ' => ['Еврейский', 'автономный округ', 'АО'],
    'Корягинский район' => ['Корягинский', 'район', 'р-н'],
    'гопотека Южное Бутово' => ['гопотека Южное Бутово'],
    'ул. Длинная' => ['Длинная', 'улица', 'ул'],
    'ул. им. Злых Марсиан-3' => ['им. Злых Марсиан-3', 'улица', 'ул'],
    'Тверь г' => ['Тверь', 'город', 'г'],
    'Тверь г.' => ['Тверь', 'город', 'г'],
    'Гаврилова' => ['Гаврилова'],
    'пр Космонавтов' => ['Космонавтов', 'проспект', 'пр-кт'],
    'Искровский проспект' => ['Искровский', 'проспект', 'пр-кт'],
    'коттеджный поселок Морозов' => ['Морозов', 'коттеджный поселок', 'кп'],
    'поселок городского типа Свердловский' => ['Свердловский', 'поселок городского типа', 'пгт'],
    'поселок Павловская Слобода' => ['Павловская Слобода', 'поселок', 'п'],
    'Павловская Слобода поселок' => ['Павловская Слобода', 'поселок', 'п'],
    'Иваново рабочий поселок' => ['Иваново', 'рабочий поселок', 'рп'],
    'ул Славянский бульвар' => ['Славянский бульвар', 'улица', 'ул'],
    'ул Набережная' => ['Набережная', 'улица', 'ул'],
    'Сокольнический Вал ул.' => ['Сокольнический Вал', 'улица', 'ул'],
    'Сокольнический Вал улица' => ['Сокольнический Вал', 'улица', 'ул'],
    'ул Сокольнический Вал' => ['Сокольнический Вал', 'улица', 'ул'],
    'улица Сокольнический Вал' => ['Сокольнический Вал', 'улица', 'ул'],
    'Курортный поселок' => ['Курортный поселок'],
    'М.Бронная ул.' => ['М.Бронная', 'улица', 'ул'],
    '1-я улица Машиностроения' => ['1-я Машиностроения', 'улица', 'ул'],
    'Аллея Ильича ул' => ['Аллея Ильича', 'улица', 'ул'],
    'ул.Сычева' => ['Сычева', 'улица', 'ул'],
    'Мира улица.' => ['Мира', 'улица', 'ул'],
    'Малаховка городского типа поселок' => ['Малаховка', 'поселок городского типа', 'пгт'],
    'Калининград город' => ['Калининград', 'город', 'г'],
    'коттеджный поселок Морозов' => ['Морозов', 'коттеджный поселок', 'кп'],
    'коттеджный Морозов' => ['Морозов', 'коттеджный поселок', 'кп'],
    'Морозов коттеджный' => ['Морозов', 'коттеджный поселок', 'кп'],
    'Морозов коттеджный поселок' => ['Морозов', 'коттеджный поселок', 'кп'],
    'Хамовнический Вал' => ['Хамовнический Вал'],
    'Аллея Ильича' => ['Аллея Ильича'],
    '' => nil,
    nil => nil,
  }.each do |name, expected|
    it "must extract status from #{name} correctly" do
      given = described_class.extract(name)
      given = given.first(3) if given.is_a?(Array)
      expect(given).to eq(expected)
    end
  end
end
