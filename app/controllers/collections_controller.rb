class CollectionsController < ApplicationController
  def index
    if params[:query].present?
      if Collection.search_by_name(params[:query]).present?
        @collections = Collection.search_by_name(params[:query])
      else
        url_metadata = RestClient.get "https://api.rarify.tech/data/contracts?filter[name]=#{params[:query]}", { Authorization: 'Bearer 6d42ff96-f7b6-4abd-8c87-b097789b71d5' }
        results = JSON.parse(url_metadata)["data"]
        results = results.select { |a| a["attributes"]["image_url"].present? && a["attributes"]["image_url"].include?("http") }
        results = results.reject { |a| Collection.all.map(&:name).include?(a["attributes"]["name"]) }
        if results.any?
          results = Collection.insert_all(
            bulk_insert_collection_params(results)
          )
        end
        @collections = Collection.where(id: results.rows.flatten)
        return @collections
      end
    else
      @collections = Collection.all
    end
  end

  def bulk_insert_collection_params(api_results)
    api_results.map do |api_result|
      {
        name: api_result["attributes"]["name"],
        description: api_result["attributes"]["description"],
        link: api_result["attributes"]["external_url"],
        image: api_result["attributes"]["image_url"]
      }
    end
  end

  def show
    @collection = Collection.find(params[:id])
  end

  private

  def collection_params
    params.require[:collection].permit(:name, :description, :image, :link)
  end
end
