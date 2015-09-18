# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_association_lessons_readings
    lesson = Lesson.create(name: "First Lesson")
    reading = Reading.create(caption: "chapter 1", url: "http://www.readingsite.comt", order_number: 1)

    lesson.readings << reading

    assert lesson.readings.include?(reading)
    assert_equal lesson.id, reading.lesson_id
  end

  def test_destroy_lesson_with_reading
    reading_before = Reading.count
    lesson_before = Lesson.count
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"http://google.com")
    reading_two = Reading.create(order_number: 2, caption:"Reading Two", url:"http://ign.com")

    lesson_one.readings << reading_one
    lesson_one.readings << reading_two

    assert_equal lesson_before + 1, Lesson.count
    assert_equal reading_before + 2, Reading.count
    assert lesson_one.destroy
    assert_equal lesson_before, Lesson.count
    assert_equal reading_before, Reading.count
  end

  def test_associate_lesson_with_course
    lesson_before = Lesson.count
    course_before = Course.count
    course_one = Course.create(name: "Course One")
    lesson_one = Lesson.create(name: "Lesson One")
    lesson_two = Lesson.create(name: "Lesson One")

    course_one.lessons << lesson_one
    course_one.lessons << lesson_two

    assert_equal course_one.id, lesson_one.course_id
    assert_equal course_one.id, lesson_two.course_id
    assert_equal course_before + 1, Course.count
    assert_equal lesson_before + 2, Lesson.count
    assert course_one.destroy
    assert_equal course_before, Course.count
    assert_equal lesson_before, Lesson.count
  end

  def test_associate_courses_with_instructors
    course = Course.create(name: "Course One")
    instructor_one = CourseInstructor.create()

    course.course_instructors << instructor_one

    assert course.course_instructors.include?(instructor_one)
  end

  def test_course_is_not_destroyed_if_has_instructor
    instructor_count = CourseInstructor.count
    course_count = Course.count

    course = Course.create(name: "Course One")
    instructor_one = CourseInstructor.create()

    course.course_instructors << instructor_one

    refute course.destroy
  end

  def test_associate_lessons_with_in_class_assignments
    lesson = Lesson.create(name: "Lesson One")
    assignment = Assignment.create(name: "Homework 1")

    assignment.lessons << lesson

    assert assignment.lessons.include?(lesson)
  end

  def test_course_has_readings_through_lessons
    course = Course.create(name: "Course One")
    lesson = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"http://google.com")
    reading_two = Reading.create(order_number: 2, caption:"Reading Two", url:"http://ign.com")

    lesson.readings << reading_one
    course.lessons << lesson

    assert course.readings.include?(reading_one)
    refute course.readings.include?(reading_two)
  end

  def test_validate_school_has_name
    high_school = School.new(name: "High School")
    no_school = School.new()

    assert high_school.save
    refute no_school.save
  end

  def test_validate_terms_have_name_starts_on_ends_on_school_id
    school = School.create(name: "High School")
    good_term = Term.new(name: "Fall", starts_on: Date.today, ends_on: Date.today + 3.months, school_id: school.id)
    bad_term = Term.new(name: "Bad", starts_on: Date.today, ends_on: Date.today + 3.months)

    assert good_term.save
    refute bad_term.save
  end

  def test_validate_user_has_email_first_last_name
    good_user = User.new(first_name: "Bruce", last_name: "Wayne", email: "the_night@imbatman.com")
    bad_user = User.new(first_name: "Harvey", last_name: "Dent")

    assert good_user.save
    refute bad_user.save
  end

  def test_email_uniqueness
    good_user = User.new(first_name: "Bruce", last_name: "Wayne", email: "batman@imbatman.com")
    bad_user = User.new(first_name: "Harvey", last_name: "Dent", email: "batman@imbatman.com")

    assert good_user.save
    refute bad_user.save
  end
  

end
