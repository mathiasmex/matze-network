module EventsHelper

  def monthname(monthnumber)
    if monthnumber
      Date::MONTHNAMES[monthnumber]
    end
  end

  def abbr_monthname(monthnumber)
    if monthnumber
      Date::ABBR_MONTHNAMES[monthnumber]
    end
  end

end
