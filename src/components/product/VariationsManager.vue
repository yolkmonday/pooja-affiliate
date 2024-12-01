<template>
  <div class="space-y-4">
    <!-- Variation Types Header -->
    <div class="flex items-center justify-between">
      <h4 class="font-medium">Product Variations</h4>
      <button
        :disabled="variationTypes.length >= 2"
        class="btn btn-sm btn-ghost inline-flex items-center"
        type="button"
        @click="addVariationType"
      >
        <svg
          class="h-4 w-4 mr-1"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <line x1="12" x2="12" y1="5" y2="19"></line>
          <line x1="5" x2="19" y1="12" y2="12"></line>
        </svg>
        Add Variation Type
      </button>
    </div>

    <!-- Variation Types List -->
    <div
      v-for="(type, typeIndex) in variationTypes"
      :key="typeIndex"
      class="space-y-4"
    >
      <div class="flex items-center space-x-4">
        <input
          v-model="type.name"
          class="input input-bordered flex-1"
          placeholder="Variation Type Name"
          type="text"
        />
        <button
          class="btn btn-ghost btn-sm"
          type="button"
          @click="removeVariationType(typeIndex)"
        >
          Remove
        </button>
      </div>

      <!-- Options List -->
      <div class="pl-4 space-y-2">
        <div
          v-for="(option, optionIndex) in type.options"
          :key="optionIndex"
          class="flex items-center space-x-4"
        >
          <input
            v-model="option.name"
            class="input input-bordered input-sm flex-1"
            placeholder="Option Name"
            type="text"
          />
          <button
            class="btn btn-ghost btn-sm"
            type="button"
            @click="removeOption(typeIndex, optionIndex)"
          >
            Remove
          </button>
        </div>

        <button
          class="btn btn-ghost btn-sm"
          type="button"
          @click="addOption(typeIndex)"
        >
          Add Option
        </button>
      </div>
    </div>

    <!-- Combinations Table -->
    <div v-if="combinations.length" class="overflow-x-auto">
      <table class="table table-compact w-full">
        <thead>
          <tr>
            <th v-for="(type, index) in variationTypes" :key="index">
              {{ type.name }}
            </th>
            <th>SKU</th>
            <th>Price Adjustment</th>
            <th>Stock</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(combo, index) in combinations" :key="index">
            <td v-for="(optionId, typeIndex) in combo.options" :key="typeIndex">
              {{ getOptionName(typeIndex, optionId) }}
            </td>
            <td>
              <input
                v-model="combo.sku"
                class="input input-xs input-bordered w-full"
                required
                type="text"
              />
            </td>
            <td>
              <input
                v-model.number="combo.price_adjustment"
                class="input input-xs input-bordered w-full"
                min="0"
                required
                type="number"
              />
            </td>
            <td>
              <input
                v-model.number="combo.stock"
                class="input input-xs input-bordered w-full"
                min="0"
                required
                type="number"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: "VariationsManager",

  data() {
    return {
      variationTypes: [],
      combinations: [],
    };
  },

  watch: {
    variationTypes: {
      deep: true,
      handler: "generateCombinations",
    },
  },

  methods: {
    addVariationType() {
      if (this.variationTypes.length >= 2) return;

      this.variationTypes.push({
        name: "",
        options: [],
      });
    },

    removeVariationType(index) {
      this.variationTypes.splice(index, 1);
    },

    addOption(typeIndex) {
      this.variationTypes[typeIndex].options.push({
        name: "",
        id: Date.now(),
      });
    },

    removeOption(typeIndex, optionIndex) {
      this.variationTypes[typeIndex].options.splice(optionIndex, 1);
    },

    getOptionName(typeIndex, optionId) {
      const option = this.variationTypes[typeIndex].options.find(
        (opt) => opt.id === optionId
      );
      return option ? option.name : "";
    },

    generateCombinations() {
      const options = this.variationTypes.map((type) =>
        type.options.map((opt) => opt.id)
      );

      if (options.some((opt) => opt.length === 0)) {
        this.combinations = [];
        return;
      }

      const getCombos = (arrays, current = []) => {
        if (arrays.length === 0) {
          return [current];
        }

        const result = [];
        const currentArray = arrays[0];
        const remainingArrays = arrays.slice(1);

        for (const item of currentArray) {
          result.push(...getCombos(remainingArrays, [...current, item]));
        }

        return result;
      };

      const newCombinations = getCombos(options).map((combo) => ({
        options: combo,
        sku: "",
        price_adjustment: 0,
        stock: 0,
      }));

      // Preserve existing values
      newCombinations.forEach((newCombo) => {
        const existingCombo = this.combinations.find(
          (combo) =>
            JSON.stringify(combo.options) === JSON.stringify(newCombo.options)
        );
        if (existingCombo) {
          newCombo.sku = existingCombo.sku;
          newCombo.price_adjustment = existingCombo.price_adjustment;
          newCombo.stock = existingCombo.stock;
        }
      });

      this.combinations = newCombinations;
    },
  },
};
</script>

<style scoped>
.space-y-4 > * + * {
  margin-top: 1rem;
}
.space-y-2 > * + * {
  margin-top: 0.5rem;
}
.space-x-4 > * + * {
  margin-left: 1rem;
}
</style>
