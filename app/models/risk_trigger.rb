class RiskTrigger < ActiveRecord::Base
  def risky?(notice)
    return false if google_defamation_notice?(notice)

    begin
      field_present?(notice) && condition_matches?(notice)
    rescue NoMethodError => ex
      Rails.logger.warn "Invalid risk trigger (#{id}): #{ex}"
      false
    end
  end

  private

  def field_present?(notice)
    notice.send(field).present?
  end

  def condition_matches?(notice)
    if negated?
      notice.send(condition_field) != condition_value
    else
      notice.send(condition_field) == condition_value
    end
  end

  def google_defamation_notice?(notice)
    (notice.submitter.try(:email) == 'google@lumendatabase.org' &&
     notice.try(:type) == 'Defamation')
  end
end
