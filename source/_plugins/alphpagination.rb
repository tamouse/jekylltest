require 'pry'

module Jekyll
  module Generators
    class AlphaPagination < Pagination
      # This generator is NOT safe from arbitrary code execution.
      safe false

      # Paginates the blog's posts. Renders the index.html file into paginated
      # directories, e.g.: page2/index.html, page3/index.html, etc and adds more
      # site-wide data.
      #
      # Uses the alphanumeric sorted list of posts modified below
      #
      # site - The Site.
      # page - The index.html Page that requires pagination.
      #
      # {"paginator" => { "page" => <Number>,
      #                   "per_page" => <Number>,
      #                   "posts" => [<Post>],
      #                   "total_posts" => <Number>,
      #                   "total_pages" => <Number>,
      #                   "previous_page" => <Number>,
      #                   "next_page" => <Number> }}
      def paginate(site, page)
        binding.pry
        all_posts = site.site_payload['site']['posts-alpha']
        pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
        (1..pages).each do |num_page|
          pager = Pager.new(site, num_page, all_posts, pages)
          if num_page > 1
            newpage = Page.new(site, site.source, page.dir, page.name)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path(site, num_page)
            site.pages << newpage
          else
            page.pager = pager
          end
        end
      end
    end
  end
end

class Jekyll::Site
  def site_payload
    {"jekyll" => { "version" => Jekyll::VERSION },
      "site" => self.config.merge({
                                    "time"       => self.time,
                                    "posts"      => self.posts.sort { |a, b| b <=> a },
                                    "posts-alpha" => self.posts.sort { |a,b| b.slug <=> a.slug },
                                    "pages"      => self.pages,
                                    "html_pages" => self.pages.reject { |page| !page.html? },
                                    "categories" => post_attr_hash('categories'),
                                    "tags"       => post_attr_hash('tags')})}
  end
end
