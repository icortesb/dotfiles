-- Adaptadores de neotest (extra test.core). Go, PHP (phpunit/pest) y Python
-- ya los agregan sus lang extras; JS/TS no trae ninguno.
return {
  {
    "nvim-neotest/neotest",
    dependencies = { "marilari88/neotest-vitest" },
    opts = {
      -- forma de diccionario: una lista reemplazaría los adapters de los lang extras
      adapters = { ["neotest-vitest"] = {} },
    },
  },
}
