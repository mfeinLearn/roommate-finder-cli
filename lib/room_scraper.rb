class RoomScraper
  def initialize(index_url)
    @index_url = index_url

    # primes @doc to get ready to scrape
    @doc = Nokogiri::HTML(open(index_url))

  end

  def call
    rows.each do |row_doc|
      Room.create_from_hash(scrape_row(row_doc)) #=> should put the room in my database.
    end
  end


  # private - their is no reason that an instance of this project to ever allow you
  # to call these methods from outside of the object
  private
    def rows
      # ||= - or equals opperator (if @rows does not already exist then search for it)
      # returning all of the words in the document
      @rows ||= @doc.search("div.content ul.rows p.result-info")
    end

    def scrape_row(row)
      # scrape an individual row
      {
        :date_created => row.search("time").attribute("datetime").text,
        :title => row.search("a.result-title.hdrlnk").text,
        :url => "#{@index_url}#{row.search("a.result-title.hdrlnk").attribute("href").text}",
        :price => row.search("span.result-price").text,
      }
    end


end
