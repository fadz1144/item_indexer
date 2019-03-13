import React, { Component } from "react";
import api from "../utils/api";
import "./Preview.css";

const isInteger = input => {
  return "" + parseInt(input) === input;
};

const Loading = () => <div className="preview-instructions">Loading...</div>;

const Instructions = () => {
  return (
    <div className="preview-instructions">
      Enter a bridge catalog db product id to preview how it is indexed.
    </div>
  );
};

const Preview = props => {
  return (
    <pre className="align-left preview">
      {JSON.stringify(props.content, null, " ")}
    </pre>
  );
};

export default class extends Component {
  constructor(props) {
    super(props);
    this.state = {
      productId: "",
      canSubmit: false,
      preview: "",
      isLoading: false,
      type: "product"
    };
  }

  onChange = e => {
    const productId = e.target.value;
    this.setState({ productId, canSubmit: isInteger(productId) });
  };

  onTypeChange = e => {
    const type = e.target.value;
    this.setState({ type });
  };

  getUrl = () => {
    const base = this.state.type === "product" ? "products" : "sku_sales_summary";
    return `${base}/${this.state.productId}.json?stream=false`;
  };

  getPlaceholder = () => this.state.type === "product" ? "product id" : "sku sales summary sales id";

  preview = e => {
    this.setState({ isLoading: true });
    fetch(api(this.getUrl()))
      .then(response => response.json())
      .then(data => this.setState({ preview: data }))
      .catch(exception => alert(`Unable to preview: ${exception}`))
      .finally(() => {
        this.setState({ isLoading: false });
      });
    e.preventDefault();
  };

  body = () => {
    const { isLoading, preview } = this.state;
    if (isLoading) {
      return <Loading />;
    } else if (preview) {
      return <Preview content={preview} />;
    } else {
      return <Instructions />;
    }
  };

  render = () => {
    const { productId, canSubmit } = this.state;
    return (
      <form onSubmit={this.preview}>
        <label>
          <input
            type="radio"
            name="type"
            value="product"
            checked={this.state.type === "product"}
            onChange={this.onTypeChange}
          />
          Product
        </label>
        <label>
          <input
            type="radio"
            name="type"
            value="skuDailySales"
            checked={this.state.type === "skuDailySales"}
            onChange={this.onTypeChange}
          />
          SKU Sales
        </label>
        <input
          value={productId}
          onChange={this.onChange}
          autoFocus
          placeholder={this.getPlaceholder()}
          className="preview-text-input"
        />
        <span>{canSubmit}</span>
        <button className="preview-button" disabled={!canSubmit}>
          Preview
        </button>
        {this.body()}
      </form>
    );
  };
}
