require 'rails_helper'

describe LoadsHelper, type: :helper do
  describe 'phone link' do
    context 'without phone' do
      let(:load) { FactoryBot.build(:load, contact_phone: nil) }

      it 'is nil' do
        expect(helper.phone_link(load)).to be_nil
      end
    end

    context 'without extension' do
      let(:load) { FactoryBot.build(:load, contact_phone_extension: nil) }

      it 'has correct number' do
        html = helper.phone_link(load)
        node = Nokogiri::HTML(html)
        expect(node.css('a')[0]['href']).to eq('tel:2125551212')
      end

      it 'displays correctly' do
        html = helper.phone_link(load)
        node = Nokogiri::HTML(html)
        expect(node.css('a')[0].text).to eq('212-555-1212')
      end
    end

    context 'with extension' do
      let(:load) { FactoryBot.build(:load, contact_phone_extension: '321') }

      it 'has correct number' do
        html = helper.phone_link(load)
        node = Nokogiri::HTML(html)
        expect(node.css('a')[0]['href']).to eq('tel:2125551212%2C%2C321')
      end

      it 'displays correctly' do
        html = helper.phone_link(load)
        node = Nokogiri::HTML(html)
        expect(node.css('a')[0].text).to eq('212-555-1212 x321')
      end
    end
  end
end
