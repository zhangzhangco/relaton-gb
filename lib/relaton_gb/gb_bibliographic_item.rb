# frozen_string_literal: true

require "relaton_iso_bib"
require "cnccs"
require "relaton_gb/gb_technical_committee"
require "relaton_gb/gb_standard_type"
require "relaton_gb/xml_parser"

module RelatonGb
  # GB bibliographic item class.
  class GbBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    # @return [RelatonGb::GbTechnicalCommittee]
    attr_reader :committee

    # @return [RelatonGb::GbStandardType]
    attr_reader :gbtype

    # @return [String]
    attr_reader :topic

    # @return [Array<Cnccs::Ccs>]
    attr_reader :ccs

    # @return [String]
    attr_reader :plan_number

    # @return [String]
    attr_reader :type, :gbplannumber

    def initialize(**args)
      super
      args[:committee] && @committee = GbTechnicalCommittee.new(args[:committee])
      @ccs = args[:ccs].map { |c| Cnccs.fetch c }
      @gbtype = GbStandardType.new args[:gbtype]
      @type = args[:type]
      @gbplannumber = args[:gbplannumber] || structuredidentifier.project_number
    end

    # @param builder [Nokogiri::XML::Builder]
    # @return [String]
    def to_xml(builder = nil, **opts)
      if builder
        super(builder, **opts) { |xml| render_gbxml(xml) }
      else
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |bldr|
          super(bldr, **opts) { |xml| render_gbxml(xml) }
        end.doc.root.to_xml
      end
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)}>"
      # "@fullIdentifier=\"#{@fetch&.shortref}\" "\
      # "@title=\"#{title}\">"
    end

    # @return [String]
    def to_s
      inspect
    end

    def makeid(id, attribute, _delim = "")
      return nil if attribute && !@id_attribute

      id ||= @docidentifier.reject { |i| i.type == "DOI" }[0]
      idstr = id.id
      # if id.part_number&.size&.positive?
      #   idstr = idstr + "-#{id.part_number}"
      # end
      idstr.gsub(/\s/, "").strip
    end

    private

    # Overraides IsoBibliographicItem method.
    # @param language [Array<String>]
    # @raise ArgumentError
    def check_language(language)
      language.each do |lang|
        unless %w[en zh].include? lang
          raise ArgumentError, "invalid language: #{lang}"
        end
      end
    end

    # Overraides IsoBibliographicItem method.
    # @param script [Array<String>]
    # @raise ArgumentError
    def check_script(script)
      script.each do |scr|
        raise ArgumentError, "invalid script: #{scr}" unless %w[Latn Hans].include? scr
      end
    end

    # @param builder [Nokogiri::XML::Builder]
    def render_gbxml(builder)
      gbtype.to_xml builder
      return unless ccs.any?

      ccs.each do |c|
        builder.ccs do
          builder.code c.code
          builder.text_ c.description
        end
      end

      builder.gbplannumber gbplannumber if gbplannumber
    end
  end
end
