module Reviews
  class Create
    attr_accessor :review

    def initialize (
      author:,
      text:,
      page:,
      rate:,
      user:,
      category:
    )

      @review = Review.new(
        author: author,
        text: text,
        page: page,
        rate: rate,
        user: user,
        category: category
      )
    end

    def call
      return nil if review.text.include? %w(dark drug deep)
      
      review.user = User.anonymous_user if review.user.nil?
      review.save
    end
  end
end
