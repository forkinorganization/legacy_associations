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

    assert_equal [reading], lesson.readings
    assert_equal lesson.id, reading.lesson_id
  end

  def test_destroy_lesson_with_reading
    reading_before = Reading.count
    lesson_before = Lesson.count
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"http://google.com", lesson_id: 1)
    reading_two = Reading.create(order_number: 2, caption:"Reading Two", url:"http://ign.com", lesson_id: 1)

    lesson_one.readings << reading_one
    lesson_one.readings << reading_two

    assert reading_one.save
    assert reading_two.save
    assert_equal lesson_before + 1, Lesson.count
    assert_equal reading_before + 2, Reading.count
    assert lesson_one.destroy
    assert_equal lesson_before, Lesson.count
    assert_equal reading_before, Reading.count
  end

end
