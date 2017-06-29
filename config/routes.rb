Rails.application.routes.draw do
  
  resources :attendances 
  get 'attendances/:attendance_id/change' => 'attendances#change', as: :change_attendance
  
  get 'statistics/index'

  get 'children_bookkeeping/payment_in'
  get 'children_bookkeeping/payment_out'
  get 'children_bookkeeping/export'
  get 'children_bookkeeping/transfer'
  get 'children_bookkeeping/child_data/:child_id' => 'shop#child_data'
  get 'children_bookkeeping/personal_transfer'

  resources :news
  resources :bookings
  resources :scouts_accounts
  resources :children_accounts
  resources :main_accounts
  post 'disbursements/clear/:id' => "disbursements#clear", as: :clear_disbursement
  resources :disbursements
  resources :settings
  resources :goods
  
  get 'scouts_bookkeeping/index'
  get 'scouts_bookkeeping/index2'
  get 'scouts_bookkeeping/consumption'
  get 'scouts_bookkeeping/overview'
  get 'scouts_bookkeeping/billing'
  get 'scouts_bookkeeping/input'
  get 'scouts_bookkeeping/payment'  
  get 'scouts_bookkeeping/count_cash'
  post 'scouts_bookkeeping/save_cash'
  get 'scouts_bookkeeping/export'
  get 'scouts_bookkeeping/export_giro'
  get 'scouts_bookkeeping/daily_closing'
  get 'scouts_bookkeeping/clear_disbursement'
  get 'scouts_bookkeeping/scout_data/:scout_id' => 'scouts_bookkeeping#scout_data'
  get 'scouts_bookkeeping/reset_cash'
  get 'scouts_bookkeeping/personal_transfer'
  post 'scouts_bookkeeping/update_accounting_no' => 'scouts_bookkeeping#update_accounting_no', as: :s_update_accounting_no
  get 'scouts_bookkeeping/cost_allocation'
  
  post 'bookings/create_payment' => 'bookings#create_payment', as: :create_payment
  post 'bookings/create_transfer' => 'bookings#create_transfer', as: :create_transfer
  post 'bookings/create_billing' => 'bookings#create_billing', as: :create_billing
  post 'bookings/create_personal_transfer' => 'bookings#create_personal_transfer', as: :create_personal_transfer
  post 'bookings/create_allocation' => 'bookings#create_allocation', as: :create_allocation
  
  post 'scouts_bookkeeping/new_entry/:scout_id' => 'scouts_bookkeeping#new_entry', as: :new_scout_consumption
  patch 'scouts_bookkeeping/update_entry/:scout_consumption_id' => 'scouts_bookkeeping#update_entry', as: :update_scout_consumption

  get 'main_bookkeeping/index'
  get 'main_bookkeeping/billing', as: :main_bookkeeping_billing
  get 'main_bookkeeping/count_cash'
  post 'main_bookkeeping/save_cash'
  get 'main_bookkeeping/export'
  get 'main_bookkeeping/daily_closing'
  post 'main_bookkeeping/update_accounting_no' => 'main_bookkeeping#update_accounting_no', as: :m_update_accounting_no
  
  get 'main_bookkeeping/clear_disbursement'
  get 'main_bookkeeping/reset_cash'
  
  get 'shop' => 'shop#index', as: :shop
  post 'shop/select_time_of_day', as: :select_time_of_day
  get 'shop/autocomplete_child_number'
  get 'shop/autocomplete_child_first_name'
  post 'shop/new_entry' => 'shop#new_entry', as: :new_child_consumption
  patch 'shop/update_entry/:child_consumption_id' => 'shop#update_entry', as: :update_child_consumption
  get 'shop/child_data/:child_id' => 'shop#child_data'

  get 'children/identify_new'
  
  get 'import/index', as: :import
  post 'import/upload', as: :upload

  resources :users
  resources :accounts
  get 'scouts/:id/export' => 'scouts#export', as: :export_scout
  resources :scouts
  resources :tents
  resources :children
  
  root 'dashboard#index', as: 'dashboard'
  post 'dashboard/select_user', as: :select_user
  post 'dashboard/select_date', as: :select_date

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
