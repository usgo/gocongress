class EditableTextsController < ApplicationController
  def index
    @editable_text = EditableText.find_or_create_by(year: @year.year)
    authorize! :manage, @editable_text
  end

  def update
    @editable_text = EditableText.find(params[:id])
    if @editable_text.update editable_text_params
      redirect_to(editable_texts_path, :notice => 'Editable text updated.')
    else
      render :action => "index"
    end
  end

  private 

  def editable_text_params
    params.require(:editable_text).permit(:welcome, :volunteers, :attendees_vip)
  end
end
