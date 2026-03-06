require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  # --- Validations ---
  test "requires check_in" do
    att = Attendance.new(employee: employees(:one), check_out: 1.hour.from_now)
    assert_not att.valid?
    assert_includes att.errors[:check_in], "can't be blank"
  end

  test "requires check_out" do
    att = Attendance.new(employee: employees(:one), check_in: Time.current)
    assert_not att.valid?
    assert_includes att.errors[:check_out], "can't be blank"
  end

  test "check_out must be after check_in" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 08:00")
    )

    assert_not attendance.valid?
    assert_includes attendance.errors[:check_out], "must be after check in"
  end

  test "check_out equal to check_in is invalid" do
    t = Time.zone.parse("2026-03-05 09:00")
    att = Attendance.new(employee: employees(:one), check_in: t, check_out: t)
    assert_not att.valid?
    assert_includes att.errors[:check_out], "must be after check in"
  end

  test "check_in is unique per employee" do
    existing = attendances(:one)

    duplicate = Attendance.new(
      employee: existing.employee,
      check_in: existing.check_in,
      check_out: existing.check_out + 1.hour
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:check_in], "has already been taken"
  end

  # --- working_hours ---
  test "working_hours returns 0 when check_in is nil" do
    att = Attendance.new(employee: employees(:one), check_out: Time.current)
    assert_equal 0, att.working_hours
  end

  test "working_hours returns 0 when check_out is nil" do
    att = Attendance.new(employee: employees(:one), check_in: Time.current)
    assert_equal 0, att.working_hours
  end

  test "working_hours returns difference in hours between check_in and check_out" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 17:30")
    )

    assert_in_delta 8.5, attendance.working_hours, 0.001
  end

  test "working_hours returns 0 when check_out is before check_in" do
    # Guard for inconsistent data
    att = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 17:00"),
      check_out: Time.zone.parse("2026-03-05 09:00")
    )
    assert_equal 0, att.working_hours
  end

  # --- ot_hours ---
  test "ot_hours is zero when working_hours is eight or less" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 17:00")
    )

    assert_in_delta 8.0, attendance.working_hours, 0.001
    assert_equal 0, attendance.ot_hours
  end

  test "ot_hours is positive only for hours beyond eight" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 19:00")
    )

    assert_in_delta 10.0, attendance.working_hours, 0.001
    assert_in_delta 2.0, attendance.ot_hours, 0.001
  end

  test "ot_hours is zero when working_hours is exactly 8" do
    att = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 17:00")
    )
    assert_equal 0, att.ot_hours
  end
end
