class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @user=@book.user
    #閲覧カウントは一人のユーザーが1つの本の投稿に関して1日に1回のみ
    @book_detail = Book.find(params[:id])
    unless ReadCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.read_counts.create(book_id: @book_detail.id)
    end
  end

  def index
    # @books = Book.all 以前まで記述していたコード
    @book = Book.new
    @user=current_user
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorites).sort_by {|x| x.favorites.where(created_at: from...to).size}.reverse
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book.id), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, )
  end


  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end


end
