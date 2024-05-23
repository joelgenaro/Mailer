module GraphQL
  module Define
    class DefinedObjectProxy
      include Rails.application.routes.url_helpers
    end
  end

  # Taken from: https://github.com/rmosolgo/graphql-ruby/issues/1530#issuecomment-511144813
  module Bebop
    module Support
      module Ransack
        def ransack(base, **args)
          base.ransack(build_ransack_query(base, **args)).result
        end

        protected

        def build_ransack_query(base, **args)
          atts = base.ransackable_attributes
          sort = args.delete(:sort)

          # Affix '_eq' to attributes without operater (eg 'name' becomes 'name_eq', vs 'name_cont')
          ransack_params = args.reduce({}) do |memo, (k,v)|
            memo[atts.include?(k.to_s) ? :"#{k}_eq" : k] = v
            memo
          end

          if sort
            # Must be permitted column name, eg 'started_at desc' 'timestamp asc'
            ransack_params[:s] = sort || 'created_at desc' # Default to created_at if none specified
          end
          
          ransack_params
        end
      end
    end
  end
end
