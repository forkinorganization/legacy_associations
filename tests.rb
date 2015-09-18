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

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_create_new_school
    pbg = School.create(name: "PBGHS")
    assert pbg.name != "highschool"
    assert pbg.name == "PBGHS"
  end

  def test_create_new_terms
    fall = Term.create(name: "Fall", starts_on: "2015-11-16",  ends_on: "2016-02-20")
    assert fall.name != "Spring"
    assert fall.name == "Fall"
    assert fall.starts_on != "2015-10-16".to_date
    assert fall.starts_on == "2015-11-16".to_date
    assert fall.ends_on != "2016-03-20".to_date
    assert fall.ends_on == "2016-02-20".to_date
  end

  def test_create_new_courses
    history = Course.create(name: "History")
    assert history.name != "English"
    assert history.name == "History"
  end

  def test_create_new_assignments
    classwork = Assignment.create(name: "Classwork")
    assert classwork.name != "Homework"
    assert classwork.name == "Classwork"
  end

  def test_create_new_lesson
    cajun_louisiana = Lesson.create( name: "Class_lesson")
    assert cajun_louisiana.name != "Class_lecture"
    assert cajun_louisiana.name == "Class_lesson"
  end

  def test_associate_school_with_terms
    pbg = School.create(name: "PBGHS")
    fall = Term.create(name: "Fall", starts_on: "2015-11-16",  ends_on: "2016-02-20")

    pbg.terms << fall

    assert pbg.terms.include?(fall)
  end

  def test_associate_terms_with_courses
    fall = Term.create(name: "Fall", starts_on: "2015-11-16",  ends_on: "2016-02-20")
    history = Course.create(name: "History")

    fall.courses << history

    assert fall.courses.include?(history)
  end

  def test_cant_destroy_courses
    fall = Term.create(name: "Fall", starts_on: "2015-11-16",  ends_on: "2016-02-20")
    history = Course.create(name: "History")

    fall.courses << history

    refute fall.destroy
  end

  # Associate courses with course_students (both directions).
  # If the course has any students associated with it, the course should not be deletable.
def test_associate_courses_with_course_students
  history = Course.create(name: "History")
  justis =  CourseStudent.create()

  history.course_students << justis

  assert history.course_students.include?(justis)
end






end
