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
    fall = Term.create(name: "Fall", starts_on: "2015-11-16",  ends_on: "2016-02-20", school_id: 1)
    assert fall.name != "Spring"
    assert fall.name == "Fall"
    assert fall.starts_on != "2015-10-16".to_date
    assert fall.starts_on == "2015-11-16".to_date
    assert fall.ends_on != "2016-03-20".to_date
    assert fall.ends_on == "2016-02-20".to_date
    assert fall.school_id != 2
    assert fall.school_id == 1
  end

  def test_create_new_courses
    history = Course.create(name: "History")
    assert history.name != "English"
    assert history.name == "History"
  end

  def create
  end



end
