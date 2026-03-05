require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "check_out must be after check_in" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 08:00")
    )

    assert_not attendance.valid?, "attendance should be invalid when check_out is before check_in"
    assert_includes attendance.errors[:check_out], "must be after check in"
  end

  test "working_hours returns difference in hours between check_in and check_out" do
    attendance = Attendance.new(
      employee: employees(:one),
      check_in: Time.zone.parse("2026-03-05 09:00"),
      check_out: Time.zone.parse("2026-03-05 17:30")
    )

    assert_in_delta 8.5, attendance.working_hours, 0.001
  end

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

  test "check_in is unique per employee" do
    existing = attendances(:one)

    duplicate = Attendance.new(
      employee: existing.employee,
      check_in: existing.check_in,
      check_out: existing.check_out + 1.hour
    )

    assert_not duplicate.valid?, "duplicate attendance with same employee and check_in should be invalid"
    assert_includes duplicate.errors[:check_in], "has already been taken"
  end
end
