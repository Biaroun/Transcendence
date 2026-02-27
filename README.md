<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/8/8d/42_Logo.svg" alt="42 logo" width="120"/>
  <h1>ft_transcendence</h1>
  <p>Projet web 42 : plateforme de jeu Pong avec architecture microservices</p>

  <p>
    <img src="https://img.shields.io/badge/Frontend-React%20%2B%20Vite-61DAFB?logo=react&logoColor=black" alt="React"/>
    <img src="https://img.shields.io/badge/Backend-Django-092E20?logo=django&logoColor=white" alt="Django"/>
    <img src="https://img.shields.io/badge/Infra-Docker%20Compose-2496ED?logo=docker&logoColor=white" alt="Docker"/>
    <img src="https://img.shields.io/badge/Proxy-Nginx-009639?logo=nginx&logoColor=white" alt="Nginx"/>
    <img src="https://img.shields.io/badge/School-42-black?logo=42&logoColor=white" alt="42"/>
  </p>
</div>

---

## 📚 Description

`ft_transcendence` est une application web multi-services orchestrée avec Docker Compose.

Le projet s’appuie sur :

- un **frontend React/Vite**
- un **reverse proxy Nginx**
- trois services **Django** (utilisateurs, pong, live chat)
- trois bases **PostgreSQL** dédiées (une par domaine)

---

## 🗂️ Architecture

- `srcs/requirements/frontend` : application React
- `srcs/requirements/nginx` : configuration TLS/proxy et exposition des services
- `srcs/requirements/service_user_handler` : service utilisateur + PostgreSQL
- `srcs/requirements/service_game_pong` : service pong + PostgreSQL
- `srcs/requirements/service_live_chat` : service chat + PostgreSQL
- `srcs/docker-compose.yml` : orchestration globale
- `scripts/set_dom.sh` : mise à jour du domaine/variables côté Nginx + frontend

---

## ⚙️ Lancement

### Prérequis

- Docker
- Docker Compose
- `make`

### Démarrer le projet

```bash
make
```

Cette commande :

- met à jour les variables de domaine (`scripts/set_dom.sh`)
- redémarre les services Compose
- initialise les réplications PostgreSQL prévues dans les conteneurs

### Arrêter et nettoyer complètement

```bash
make fclean
```

---

## 🌐 Accès

- HTTPS : `https://localhost:4343`
- HTTP : `http://localhost:8080`

---

## 🧪 Debug

Pour afficher rapidement les pages d’erreurs Nginx de test :

```bash
make debug_nginx
```

---

## 👤 Auteur

- `biaroun` — 42
- `mgayout` — 42
- `mcordes` — 42

---

## 📄 Licence

Projet académique 42.
Usage pédagogique et personnel.
