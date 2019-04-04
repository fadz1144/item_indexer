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
      isLoading: false
    };
  }

  onChange = e => {
    const productId = e.target.value;
    this.setState({ productId, canSubmit: isInteger(productId) });
  };

  preview = e => {
    this.setState({ isLoading: true });
    fetch(api(`products/${this.state.productId}.json?stream=false`))
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
        <input
          value={productId}
          onChange={this.onChange}
          autoFocus
          placeholder="product id"
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
