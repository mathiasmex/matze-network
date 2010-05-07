module BlogsHelper
  def blog_tab_path(blog)
    if blog.owner.class.to_s == "Person"
      person_path(blog.owner, :anchor => "tBlog")
    else
      group_path(blog.owner, :anchor => "tBlog")
    end
  end

  def blog_tab_url(blog)
    if blog.owner.class.to_s == "Person"
      person_url(blog.owner, :anchor => "tBlog")
    else
      group_url(blog.owner, :anchor => "tBlog")
    end
  end  
end
