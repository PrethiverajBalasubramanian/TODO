class TimestampOrCronValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_timestamp?(value) || valid_cron?(value)
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def valid_timestamp?(value)
    debugger
    Time.zone.parse(value.to_s) > Time.current
  rescue ArgumentError, TypeError
    false
  end

  def valid_cron?(value)
    require 'fugit'
    Fugit::Cron.parse(value).present?
  rescue
    false
  end
end