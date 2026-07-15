# frozen_string_literal: true

module Jekyll
  class BlogPages < Generator
    safe true
    priority :low

    def generate(site)
      sections = {}

      site.pages.each do |page|
        next unless page.path.start_with?("blogs/")
        next if page.path == "blogs/index.md"

        relative_path = page.path.delete_prefix("blogs/").sub(/\.[^.]+\z/, "")
        path_parts = relative_path.split("/")
        directory_parts = path_parts[0...-1]

        page.data["blog_section"] ||= directory_parts.first
        page.data["blog_directory"] ||= directory_parts.join("/")
        page.data["title"] ||= path_parts.last
        page.data["permalink"] ||= "/blogs/#{path_parts.map { |part| Utils.slugify(part) }.join("/")}/"

        directory_parts.each_index do |index|
          parts = directory_parts[0..index]
          path = parts.join("/")
          sections[path] ||= {
            "name" => parts.last,
            "path" => path,
            "depth" => index,
            "parent" => index.zero? ? nil : parts[0...-1].join("/"),
            "count" => 0,
            "pages" => []
          }
          sections[path]["count"] += 1
        end

        sections[directory_parts.join("/")]["pages"] << page unless directory_parts.empty?
      end

      site.data["blog_sections"] = sections.values.sort_by { |section| section["path"].downcase }
    end
  end
end
