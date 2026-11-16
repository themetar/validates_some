# frozen_string_literal: true

require "test_helper"

class User < ActiveRecord::Base

  validates :name, presence: true
  validates :nickname, presence: true, length: { minimum: 4 }, format: /\A[a-zA-Z]+\z/
  validates :surname, presence: true
  validates_some :name, :nickname, :surname

  validates :phone_number, format: /\d{8}/
  validates :email, format: /\w+@\w{3}/
  validates_some :phone_number, :email, resets: ["XXYYYZZZ", ""]
  validates :email, uniqueness: true, allow_blank: true # check uniqueness for valid emails

  validates :home_address, :work_address, presence: true
  validates_some :home_address, :work_address, resets: proc { |attr| "No #{attr.to_s.tr("_", " ")}" }

end

class TestValidatesSome < Minitest::Test

  include ActiveSupport::Testing::Assertions

  def test_that_it_has_a_version_number
    refute_nil ::ValidatesSome::VERSION
  end

  def test_it_saves_fully_filled_user
    user = User.new(name: "John", nickname: "Cool", surname: "Smith",
                    phone_number: "22333444", email: "hello@org",
                    home_address: "Some St. 42", work_address: "Some Ave. 1")

    # assert it passes validations
    assert user.valid?

    # assert it saves
    assert_difference "User.count", 1 do
      user.save
    end

    # assert attributes are unchanged
    assert_equal "John", user.name
    assert_equal "Cool", user.nickname
    assert_equal "Smith", user.surname
    assert_equal "22333444", user.phone_number
    assert_equal "hello@org", user.email
    assert_equal "Some St. 42", user.home_address
    assert_equal "Some Ave. 1", user.work_address

    # assert no validation errors
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_no_name
    # assert it passes validations and saves
    user = assert_difference "User.count", 1 do
      User.create(nickname: "Cool", surname: "Smith",
                  phone_number: "22333444", email: MiniFaker.email,
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_nil user.name
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_no_surname
    user = assert_difference "User.count", 1 do
      User.create(name: "John", nickname: "Cool",
                  phone_number: "22333444", email: MiniFaker.email,
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_nil user.surname
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_no_nickname
    user = assert_difference "User.count", 1 do
      User.create(name: "John", surname: "Smith",
                  phone_number: "22333444", email: MiniFaker.email,
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_nil user.nickname
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_bad_nickname
    user = assert_difference "User.count", 1 do
      User.create(name: "John", nickname: "JS",
                  phone_number: "22333444",
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_nil user.nickname # gets reset to `nil`
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_just_a_name
    user = assert_difference "User.count", 1 do
      User.create(name: "John",
                  phone_number: "22333444", email: MiniFaker.email,
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_nil user.nickname
    assert_nil user.surname
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_just_a_nickname
    user = assert_difference "User.count", 1 do
      User.create(nickname: "Cool",
                  phone_number: "22333444", email: MiniFaker.email,
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_nil user.name
    assert_nil user.surname
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_just_a_surname
    user = assert_difference "User.count", 1 do
      User.create(surname: "Smith",
                  phone_number: "22333444", email: MiniFaker.email,
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_nil user.name
    assert_nil user.nickname
    # assert error status
    assert_empty user.errors
  end

  def test_it_doesnt_save_a_user_without_any_naming_info
    user = assert_no_difference "User.count" do
      User.create(phone_number: "22333444", email: MiniFaker.email,
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_nil user.name
    assert_nil user.nickname
    assert_nil user.surname
    # assert error status
    assert_equal %i[name nickname surname], user.errors.map(&:attribute).uniq
    assert_equal 3, user.errors[:nickname].size # fails three validations
  end

  def test_it_doesnt_save_a_user_with_bad_nickname_and_no_other_naming_info
    user = assert_no_difference "User.count" do
      User.create(nickname: "C1",
                  phone_number: "22333444", email: MiniFaker.email,
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_nil user.name
    assert_equal "C1", user.nickname # doesn't get reset
    assert_nil user.surname
    # assert error status
    assert_equal %i[name nickname surname], user.errors.map(&:attribute).uniq
    assert_equal 2, user.errors[:nickname].size # show that both validation errors are present
  end

  def test_it_saves_a_user_without_a_phone_number
    user = assert_difference "User.count", 1 do
      User.create(name: "John", surname: "Smith",
                  email: MiniFaker.email,
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_equal "XXYYYZZZ", user.phone_number
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_an_invalid_phone_number
    user = assert_difference "User.count", 1 do
      User.create(name: "John", surname: "Smith",
                  phone_number: "123", email: MiniFaker.email,
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_equal "XXYYYZZZ", user.phone_number
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_without_an_email
    user = assert_difference "User.count", 1 do
      User.create(name: "John",
                  phone_number: "22333444",
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_empty user.email
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_an_invalid_email
    user = assert_difference "User.count", 1 do
      User.create(name: "John",
                  phone_number: "22333444", email: "aaa%%%",
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_empty user.email
    # assert error status
    assert_empty user.errors
  end

  def test_it_doesnt_save_a_user_without_any_contact_info
    user = assert_no_difference "User.count" do
      User.create(name: "John", surname: "Smith",
                  work_address: "Some Ave. 1")
    end

    # assert no resets
    assert_nil user.phone_number
    assert_nil user.email
    # assert error status
    assert_equal %i[phone_number email], user.errors.map(&:attribute)
  end

  def test_it_doesnt_save_a_user_with_bad_contact_info
    user = assert_no_difference "User.count" do
      User.create(name: "John", surname: "Smith",
                  phone_number: "456", email: "!!!",
                  home_address: "Some St. 42")
    end

    # assert no resets
    assert_equal "456", user.phone_number
    assert_equal "!!!", user.email
    # assert error status
    assert_equal %i[phone_number email], user.errors.map(&:attribute)
  end

  def test_it_validates_email_uniqueness
    # use an email
    User.create(name: "John",
                email: "first@org",
                work_address: "Some Ave. 1")

    # can't reuse it again
    user = assert_no_difference "User.count" do
      User.create(name: "Alice",
                  email: "first@org",
                  work_address: "Some Ave. 1")
    end

    # assert error status
    assert_equal %i[email], user.errors.map(&:attribute)
    assert user.errors.of_kind? :email, :taken
  end

  def test_it_validates_email_uniqueness_even_if_phone_number_is_valid
    # use an email
    User.create(name: "John",
                email: "second@org",
                work_address: "Some Ave. 1")

    # can't reuse it again
    user = assert_no_difference "User.count" do
      User.create(name: "Alice",
                  phone_number: "22333444", email: "second@org",
                  work_address: "Some Ave. 1")
    end

    # assert error status
    assert_equal %i[email], user.errors.map(&:attribute)
    assert user.errors.of_kind? :email, :taken
  end

  def test_it_saves_a_user_with_no_home_address
    user = assert_difference "User.count", 1 do
      User.create(name: "John",
                  phone_number: "22333444",
                  work_address: "Some Ave. 1")
    end

    # assert resets
    assert_equal "No home address", user.home_address
    # assert error status
    assert_empty user.errors
  end

  def test_it_saves_a_user_with_no_work_address
    user = assert_difference "User.count", 1 do
      User.create(name: "John",
                  phone_number: "22333444",
                  home_address: "Some St. 42")
    end

    # assert resets
    assert_equal "No work address", user.work_address
    # assert error status
    assert_empty user.errors
  end

  def test_it_doesnt_save_a_user_with_no_addresses
    user = assert_no_difference "User.count" do
      User.create(name: "John",
                  phone_number: "22333444")
    end

    # assert no resets
    assert_nil user.home_address
    assert_nil user.work_address
    # assert error status
    assert_equal %i[home_address work_address], user.errors.map(&:attribute)
  end

end
