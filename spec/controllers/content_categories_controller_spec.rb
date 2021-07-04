# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentCategoriesController, type: 'controller' do
  describe 'create' do
    it 'redirects to #show' do
      year = 2021
      atrs = attributes_for(:content_category)
        .slice(:name, :table_of_contents, :ordinal, :url)
      admin = create :admin, year: year
      sign_in admin
      expect {
        post :create, params: { content_category: atrs, year: year }
      }.to(change { ::ContentCategory.count }.by(+1))
      cat = ::ContentCategory.last
      expect(response).to redirect_to(cat)
    end
  end

  describe 'destroy' do
    it 'deletes record, redirects to #index' do
      year = 2021
      cat = create :content_category, year: year
      admin = create :admin, year: year
      sign_in admin
      expect {
        delete :destroy, params: { id: cat, year: year }
      }.to(change { ::ContentCategory.count }.by(-1))
      expect(response).to redirect_to(content_categories_path)
    end
  end

  describe 'edit' do
    it 'assigns @content_category' do
      year = 2021
      cat = create :content_category, year: year
      admin = create :admin, year: year
      sign_in admin
      get :show, params: { id: cat.id, year: year }
      expect(assigns(:content_category)).to eq(cat)
      expect(response.status).to eq(200)
    end
  end

  describe 'index' do
    it 'assigns @content_categories' do
      year = 2021
      cats = create_list :content_category, 2, year: year
      admin = create :admin, year: year
      sign_in admin
      get :index, params: { year: year }
      expect(assigns(:content_categories)).to eq(cats)
      expect(response.status).to eq(200)
    end
  end

  describe 'new' do
    it 'assigns @content_category' do
      year = 2021
      admin = create :admin, year: year
      sign_in admin
      get :new, params: { year: year }
      cat = assigns(:content_category)
      expect(cat).to be_a(::ContentCategory)
      expect(cat.year).to eq(year)
      expect(response.status).to eq(200)
    end
  end

  describe 'show' do
    it 'assigns @content_category and @contents' do
      year = 2021
      cat = create :content_category, year: year
      contents = create_list :content, 2, content_category: cat, year: year
      admin = create :admin, year: year
      sign_in admin
      get :show, params: { id: cat.id, year: year }
      expect(assigns(:content_category)).to eq(cat)
      expect(assigns(:contents)).to eq(contents)
      expect(response.status).to eq(200)
    end
  end

  describe 'update' do
    it 'redirects to #show' do
      year = 2021
      cat = create :content_category, year: year
      atrs = attributes_for(:content_category).slice(:name)
      admin = create :admin, year: year
      sign_in admin
      patch :update, params: { content_category: atrs, id: cat.id, year: year }
      expect(cat.reload.name).to eq(atrs.fetch(:name))
      expect(response).to redirect_to(cat)
    end
  end
end
