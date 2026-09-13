from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm
from django.shortcuts import render
from django.urls import reverse_lazy
from django.views.generic import CreateView, TemplateView

User = get_user_model()


def page_not_found(request, exception):
    return render(request, 'pages/404.html', status=404)


def csrf_failure(request, reason=''):
    return render(request, 'pages/403csrf.html', status=403)


def page_not_found_500(request):
    return render(request, 'pages/500.html', status=500)


class AboutPageView(TemplateView):
    template_name = 'pages/about.html'


class RulesPageView(TemplateView):
    template_name = 'pages/rules.html'


class RegistrationView(CreateView):
    form_class = UserCreationForm
    template_name = 'registration/registration_form.html'
    success_url = reverse_lazy('login')
