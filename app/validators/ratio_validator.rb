class RatioValidator < ActiveModel::Validator
  def validate(record)
    if record.protein_ratio and record.carbohydrate_ratio and record.fat_ratio
      if (record.protein_ratio + record.carbohydrate_ratio + record.fat_ratio) != 100.0
        record.errors[:base] << "Percentages must add up to 100"
      end
    end
  end
end