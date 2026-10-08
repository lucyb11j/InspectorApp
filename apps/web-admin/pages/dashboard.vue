<template>
  <div class="dashboard-page">
    <header class="header">
      <h1>Welcome back, {{ user?.email }}</h1>
      <p class="subtitle">Here's an overview of your inspections and properties.</p>
    </header>

    <div class="stats-grid">
      <div class="stat-card">
        <h3>Total Inspections</h3>
        <p class="value">0</p>
      </div>
      <div class="stat-card">
        <h3>Pending Reports</h3>
        <p class="value">0</p>
      </div>
      <div class="stat-card">
        <h3>Active Properties</h3>
        <p class="value">0</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const user = useSupabaseUser()
</script>

<style scoped>
.header {
  margin-bottom: 40px;
}
.header h1 {
  font-size: 2.2rem;
  margin-bottom: 8px;
}
.subtitle {
  color: var(--text-secondary);
  font-size: 1.1rem;
}
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
}
.stat-card {
  background: var(--surface-dark);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  transition: var(--transition);
}
.stat-card:hover {
  transform: translateY(-5px);
  border-color: rgba(255, 255, 255, 0.1);
}
.stat-card h3 {
  color: var(--text-secondary);
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-top: 0;
}
.stat-card .value {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 10px 0 0 0;
  color: var(--primary);
}
</style>
