# Quartermaster


## Admin Panel

Add this line to your `config/routes.rb`

```ruby
MyApp::Application.routes.draw do
  mount Quartermaster::Engine => "/quartermaster"
end
```
