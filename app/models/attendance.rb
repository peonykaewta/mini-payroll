class Attendance < ApplicationRecord
  belongs_to :employee

  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :check_in, uniqueness: { scope: :employee_id }

  validate :checkout_after_checkin

  def checkout_after_checkin
    return if check_out.nil? || check_in.nil?

    if check_out <= check_in
      errors.add(:check_out, "must be after check in")
    end
  end

  def working_hours
    return 0 if check_in.nil? || check_out.nil?
    seconds = check_out - check_in
    return 0 if seconds.nil? || seconds <= 0
    (seconds / 3600.0).to_f
  end

  def ot_hours
    hours = working_hours
    return 0 if hours.nil? || !hours.is_a?(Numeric) || hours <= 0
    hours > 8 ? hours - 8 : 0
  end
end
