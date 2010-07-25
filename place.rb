require "httparty"
require 'nokogiri'
require "json"

class Place
  FIELD_LIST = [{ :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trRegisterID",               :output_name => 'register_no',          :processor => :h6_single },
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trRegistrationType",         :output_name => 'registration_type',     :processor => :h6_nested_span},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trRegion",                   :output_name => 'region',               :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trDateRegistered",           :output_name => 'date_registered',      :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trCouncil",                  :output_name => 'council',              :processor => :h6_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLegalDescription",         :output_name => "legal_description",    :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trOtherNames",               :output_name => 'other_names',          :processor => :h6_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trBriefDescription",         :output_name => 'history',              :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trCurrentUse",               :output_name => 'current_use',          :processor => :h6_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trFormer",                   :output_name => 'former_uses',          :processor => :h6_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trConstructionDates",        :output_name => 'construction_dates',   :processor => :h6_span_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trConstructionProfessional", :output_name => 'other_info',           :processor => :h6_ul_a},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trEntryBy",                  :output_name => 'entry_by',             :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trEntryDate",                :output_name => "Entry Date",           :processor => :h6_single},
                
                #Need to convert geo data - Source data does not yet have the correct easting and northing data
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trGPSReferences",            :output_name => 'gps_ref',              :processor => :h6_ul},

                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trInformationSources",       :output_name => "information_sources",  :processor => :h6_ul},

                { :html_id => "sListingImages",                                           :output_name => "images",               :processor => :listing_images},
                
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trInformationSources",       :output_name => "information_sources",  :processor => :h6_ul},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trAssociatedListings",       :output_name => "associated_listings",  :processor => :h6_ul_a},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trConstructionDetails",       :output_name => "construction_details", :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trCulturalSignificance",      :output_name => "cultural_significance",:processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trDOCManaged",                :output_name => "doc_managed",          :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trDetailSection23",           :output_name => "detail_section_23",    :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trHeritageCovenant",          :output_name => "heritage_convenant",   :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trHistoricalNarrative",       :output_name => "historical_narative",  :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trHistoricalSignificance",    :output_name => "historical_significance",:processor => :h6_single},

                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLinks",                     :output_name => "links",                  :processor => :links},

                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLocationDescription",       :output_name => "location_description",   :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trNotableFeatures",           :output_name => "notable_features",       :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trOtherInformation",          :output_name => "other_informtion",       :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trPhysicalDescription",       :output_name => "physical_description",   :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trPhysicalSignificance",      :output_name => "pysical_significance",   :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trStatusExplanation",         :output_name => "status_explanation",     :processor => :h6_single},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trrsNZMS260",                 :output_name => "rs_nzms_260",            :processor => :h6_ul},

                #No content in these fields
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trOtherNames2",               :output_name => "other_names_2",          :processor => nil},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trCouncil2",                  :output_name => "council_2",            :processor => nil},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLegalDescription2",         :output_name => "legal_description_2",    :processor => nil},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLinksbr",                   :output_name => "links_br",               :processor => nil},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trLocationDescription2",      :output_name => "location_description_2", :processor => nil},
                { :html_id => "ctl12_ctl02_PropertyRPT_ctl00_trRegisterID2",               :output_name => "register_id_2",          :processor => nil}]

  include HTTParty
  # debug_output
  base_uri "http://www.historic.org.nz"
  attr_accessor :log
  @log = nil
  def initialize(place_id, overwrite = false)
    #Set up some logging if we need it
    self.log = Logger.new("errors.log")
    self.log.level = Logger::WARN
  
    @place_id = place_id
  
    # Check to see if the html file exists or if we have a skipped ID. Skipped ID's are ones that don't exist on the server
    # Default is to hit this cache and not download the file again.
    if File.exists?("raw/#{place_id}.html") && (overwrite == false)
      @record = File.new("raw/#{place_id}.html").read
    elsif File.exists?("raw/#{place_id}.skip") && (overwrite == false)
      @record = File.new("raw/#{place_id}.skip").read
    else
      #Be nice to the server and stop from between 0 and 3 seconds between requests
      sleep rand(3)
      @record = self.class.get("/TheRegister/RegisterSearch/RegisterResults.aspx?RID=#{place_id}&m=advanced")
    end
    
    #Get the raw doc parsed
    @doc = Nokogiri::HTML(@record)
    
    #No result ID in the source means that we don't have a search result for that ID
    if @doc.at_css("#ctl12_ctl02_dNoResult")
      @valid_record = false
      false
    else
      @valid_record = true
      true
    end
  end

  def raw
    @record
  end

  def place_id
    @place_id
  end

  def valid_record?
    @valid_record
  end

  def to_json
    get_fields.to_json
  end

  def formatted_fields
    get_fields
  end

  def possible_fields
    @doc.css("div").map { |field| (field.attributes["id"] && (field.attributes["id"].value.start_with?("ctl12_ctl02_PropertyRPT_ctl00") && !field.attributes["id"].value.end_with?("b")) ? field.attributes["id"].value : nil) }.uniq().compact
  end

  private
  def get_fields
    o = {}
    FIELD_LIST.each do |field|
      case field[:processor]
      when :h6_single
        o[field[:output_name].to_sym] = @doc.css("##{field[:html_id]}").children.map { |text| text_field_content(text) }.to_s
      when :h6_nested_span
        str = @doc.css("##{field[:html_id]}").children.map { |text| text_field_content(text) }.to_s
        str += @doc.css("##{field[:html_id]} span").children.map { |text| text_field_content(text) }.to_s
        o[field[:output_name].to_sym] = str
      when :h6_ul
        o[field[:output_name].to_sym] = @doc.css("##{field[:html_id]} ul").children.map { |text| strip_chars(text.content) }
      when :h6_span_ul
        o[field[:output_name].to_sym] = @doc.css("##{field[:html_id]} span ul").children.map { |text| strip_chars(text.content) }
      when :h6_ul_a
        o[field[:output_name].to_sym] = @doc.css("##{field[:html_id]} ul").children.map { |text| strip_chars(text.content) }
      when :listing_images
        images = extract_images(@doc.css(".#{field[:html_id]}"))
        o[field[:output_name].to_sym] = images
      when :links
        links = extract_links(@doc.css("##{field[:html_id]}"))
        o[field[:output_name].to_sym] = links
      else
        #Throw up any missing data so we can add a processor for it
        text = @doc.css("##{field[:html_id]}").inner_text
        text = strip_chars(text)
        if text.size > 0
          log.warn("Processor (#{place_id}): #{field[:html_id].to_s}")
          log.warn("#{text}")          
        end
      end
    end
    o
  end
  
  def text_field_content(field)
    (field.text? ? field.content.strip : "").gsub("\302\240", "")
  end
  
  def strip_chars(field)
    field.gsub("\302\240", "").strip
  end
  
  def extract_images(image_table)
    images = []
    image_table.css("a").each do |a|
      image = a.attributes["href"].value
      images << {:url => image.gsub("../../", "http://www.historic.org.nz/"), :title => a.attributes["title"].value} if image.end_with?("lg.jpg")
    end
    
    images.uniq
  end

  def extract_links(link_html)
    links = []
    link_html.css("a").each do |a|
      link = a.attributes["href"].value
      links << {:url => link, :title => a.inner_text}
    end
    
    links.uniq
  end 
end