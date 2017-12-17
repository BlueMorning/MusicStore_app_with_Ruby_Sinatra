require_relative('./../helper/dbhelper')
require_relative('./../helper/navigation')


class Artist

  attr_reader :art_id, :art_name
  attr_accessor :art_name, :art_photo, :art_photo_path, :nav_to_albums, :nav_to_edit_form, :nav_to_delete

  def initialize(options)
    @art_id             = options['art_id'] if options['art_id']
    @art_name           = options['art_name']
    @art_photo          = @art_name.downcase.sub(" ","")
    @art_photo_path     = NavMusicStore::DATA_IMAGES_PATH + @art_photo + ".jpg"
    @nav_to_albums      = NavStockAlbums::GET_WITH_FILTERS + "art_id=#{@art_id}"
    @nav_to_edit_form   = NavArtists.nav_get_edit_by_id(@art_id)
    @nav_to_delete      = NavArtists.nav_post_delete_by_id(@art_id)
  end


  # Perform an insert or an update depending on the value of art_id
  def save()
    if(@art_id) #if the row already exists
      update()
    else
      insert()
    end
  end




  # Class methods
  def self.link_create_new_artist()
    return NavArtists::GET_NEW
  end


  # Delete from the table artists the given object and return the object
  def self.delete(artist)
    query   = "DELETE FROM artists WHERE art_id = $1"
    DbHelper.run_sql(query, [artist.art_id])
    return artist
  end

  # Delete from the table artists the given art_id
  def self.delete_by_id(art_id)
    query   = "DELETE FROM artists WHERE art_id = $1"
    DbHelper.run_sql(query, [art_id])
  end

  # Find the artist on the given art_id
  def self.find_by_id(art_id)
    query   = "SELECT art_id, art_name FROM artists WHERE art_id = $1"
    return DbHelper.run_sql_and_return_one_object(query, [art_id], Artist)
  end

  # Find all the artists whose name matches
  def self.find_all()
    query   = "SELECT art_id, art_name FROM artists"
    return DbHelper.run_sql_and_return_many_objects(query, [], Artist)
  end

  # Find all the artists
  def self.search_all_by_name(art_name)
    query   = "SELECT art_id, art_name FROM artists WHERE lower(art_name) LIKE lower($1) #{DbHelper::NB_ROWS_LIMIT}"
    return DbHelper.run_sql_and_return_many_objects(query, ["%#{art_name}%"], Artist)
  end


  private

  # Insert the artist in the Artist table
  def insert()
    query   = "INSERT INTO artists (art_name, art_photo) VALUES ($1, $2) RETURNING art_id"
    @art_id = DbHelper.run_sql_return_first_row_column_value(query, [@art_name, @art_photo], 'art_id');
  end

  # Update the artist in the Artist table
  def update()
    query   = "UPDATE artists SET art_name = $1, art_photo = $2 WHERE art_id = $3"
    DbHelper.run_sql(query, [@art_name, @art_photo, @art_id])
  end


end
