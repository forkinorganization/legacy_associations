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

  def test_associate_lessons_with_assignments
    lesson = Lesson.create(name: "Lesson One")
    assignment = Assignment.create(name: "Homework 1")

    assignment.lessons << lesson

    assert assignment.lessons.include?(lesson)
  end

end
