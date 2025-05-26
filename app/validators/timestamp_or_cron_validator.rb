class TimestampOrCronValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_timestamp?(value) || valid_cron?(value)
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def valid_timestamp?(value)
    Time.zone.parse(value.to_s).in_time_zone("Asia/Kolkata").iso8601 > Time.current.in_time_zone("Asia/Kolkata").iso8601
  rescue ArgumentError, TypeError
    false
  end

  def valid_cron?(value)
    require "fugit"
    Fugit::Cron.parse(value).present?
  rescue
    false
  end
end
