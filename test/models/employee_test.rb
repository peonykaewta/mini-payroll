require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "working_days counts attendances" do
    employee = Employee.create!(name: "Tester", position: "Dev", base_salary: 30_000)

    2.times do |i|
      Attendance.create!(
        employee: employee,
        check_in: Time.zone.local(2026, 3, 5 + i, 9, 0, 0),
        check_out: Time.zone.local(2026, 3, 5 + i, 17, 0, 0)
      )
    end

    assert_equal 2, employee.working_days
  end

  test "ot_hours sums up ot_hours from attendances" do
    employee = Employee.create!(name: "OT Tester", position: "Dev", base_salary: 30_000)

    # 9 hours -> 1 hour OT
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 18, 0, 0)
    )

    # 10 hours -> 2 hours OT
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 6, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 6, 19, 0, 0)
    )

    assert_in_delta 3.0, employee.ot_hours, 0.001
  end

  test "ot_rate is base salary divided by 30 days and 8 hours" do
    employee = Employee.new(name: "Rate Tester", position: "Dev", base_salary: 30_000)

    expected_rate = 30_000.0 / 30.0 / 8.0
    assert_in_delta expected_rate, employee.ot_rate, 0.001
  end

  test "tax is calculated with progressive brackets" do
    employee = Employee.new(name: "Tax Tester", position: "Dev", base_salary: 60_000)

    # income = 60_000, so:
    # over 50_000 -> (60_000 - 50_000) * 0.10 = 1_000
    # remaining income = 50_000
    # over 30_000 -> (50_000 - 30_000) * 0.05 = 1_000
    # total tax = 2_000
    assert_in_delta 2_000.0, employee.tax, 0.001
  end

  test "net_pay equals base salary plus ot_pay minus tax" do
    employee = Employee.create!(name: "Net Tester", position: "Dev", base_salary: 30_000)

    # One day with 10 hours work -> 2 hours OT
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 19, 0, 0)
    )

    expected_ot_pay = employee.ot_hours * employee.ot_rate
    expected_net_pay = employee.base_salary + expected_ot_pay - employee.tax

    assert_in_delta expected_net_pay, employee.net_pay, 0.001
  end
end
