class Sorter
  
  def self.sort_by_fecha(sort,data)
    
    if sort.present?
      sort == "ASC" ? data = data.sort_by(&:fecha) : data = data.sort_by(&:fecha).reverse!
    else
      data = data.sort_by(&:fecha).reverse!
    end

    data

  end

end
