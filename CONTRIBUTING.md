# Contributing to CIS Benchmark Compliance-as-Code Framework

Thank you for your interest in contributing to this project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in GitHub Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment details (OS, tool versions)

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/crystal-nova.git
   cd crystal-nova
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/new-cis-control
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests for new functionality
   - Update documentation

4. **Test your changes**
   ```bash
   # Run Checkov
   ./scripts/run_checkov.sh
   
   # Test OPA policies
   ./tests/test_rego_policies.sh
   
   # Validate Terraform
   cd iac/aws
   terraform init
   terraform validate
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add CIS control X.Y for [resource]"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/new-cis-control
   ```

7. **Open a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Ensure CI/CD checks pass

## Development Guidelines

### Code Style

**Terraform:**
- Use `terraform fmt` before committing
- Follow HashiCorp naming conventions
- Add comments for complex logic

**Python:**
- Follow PEP 8 style guide
- Use type hints where applicable
- Add docstrings for functions

**Rego (OPA):**
- Use descriptive rule names
- Add comments explaining policy logic
- Include examples in comments

**InSpec:**
- Use descriptive control IDs
- Include impact and description
- Reference CIS control numbers

### Adding New CIS Controls

1. **Update control mapping**
   - Edit `docs/control_mapping.md`
   - Add control ID, description, and implementation details

2. **Add IaC checks**
   - Update `.checkov.yaml` if using built-in checks
   - Add custom Rego policy in `policies/opa/` if needed

3. **Add runtime checks**
   - Create InSpec control in `policies/inspec/aws-cis-benchmark/controls/`
   - Follow existing control structure

4. **Add remediation**
   - Create Cloud Custodian policy in `policies/custodian/`
   - Test in dry-run mode first

5. **Update documentation**
   - Update README.md coverage table
   - Add to user guide if needed

### Testing Requirements

All contributions must include:

- **Unit tests** for OPA policies
- **Integration tests** for Terraform code
- **Documentation** updates
- **Passing CI/CD** checks

### Commit Message Format

Use conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding tests
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

**Example:**
```
feat(inspec): Add CIS 3.1 CloudWatch monitoring control

- Implement InSpec control for CIS 3.1
- Add Cloud Custodian remediation policy
- Update control mapping documentation

Closes #123
```

## Code Review Process

1. Maintainers will review your PR within 3-5 business days
2. Address any feedback or requested changes
3. Once approved, maintainers will merge your PR

## Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md)

## Questions?

- Open a GitHub Discussion
- Check existing documentation
- Contact the maintainers

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---
Thank you for contributing to making cloud compliance easier for everyone! 🎉
